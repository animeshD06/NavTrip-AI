import assert from 'node:assert/strict';
import test from 'node:test';

import request from 'supertest';

process.env.DATABASE_URL = '';
process.env.JWT_SECRET = 'test-secret';

const { default: app } = await import('../src/app.js');

test('health endpoint reports ok', async () => {
  const response = await request(app).get('/api/health').expect(200);

  assert.equal(response.body.status, 'ok');
  assert.equal(response.body.database.connected, false);
});

test('places endpoint returns Jaipur places', async () => {
  const response = await request(app)
    .get('/api/places')
    .query({ city: 'Jaipur', category: 'historical' })
    .expect(200);

  assert.ok(response.body.data.length >= 3);
  assert.equal(response.body.data[0].city, 'Jaipur');
});

test('places endpoint includes locations imported from markdown', async () => {
  const response = await request(app)
    .get('/api/places')
    .query({ city: 'Udaipur' })
    .expect(200);

  assert.equal(response.body.data.length, 12);
  assert.ok(
    response.body.data.some((place) => place.name === 'Lake Pichola'),
  );
});

test('nearby endpoint validates latitude', async () => {
  const response = await request(app)
    .get('/api/places/nearby')
    .query({ latitude: 999, longitude: 75 })
    .expect(400);

  assert.equal(response.body.error, 'BadRequest');
});

test('auth endpoints validate email and password inputs', async () => {
  const badEmailResponse = await request(app)
    .post('/api/auth/register')
    .send({
      name: 'Bad Email',
      email: 'not-an-email',
      password: 'password123',
    })
    .expect(400);

  assert.equal(badEmailResponse.body.error, 'BadRequest');

  const shortPasswordResponse = await request(app)
    .post('/api/auth/register')
    .send({
      name: 'Short Password',
      email: 'short@example.com',
      password: 'short',
    })
    .expect(400);

  assert.equal(shortPasswordResponse.body.error, 'BadRequest');
});

test('register, create trip, list trip, and delete trip', async () => {
  const email = `api-${Date.now()}@example.com`;
  const registerResponse = await request(app)
    .post('/api/auth/register')
    .send({
      name: 'API Test',
      email,
      password: 'password123',
    })
    .expect(201);

  const token = registerResponse.body.data.token;
  assert.ok(token);

  const tripResponse = await request(app)
    .post('/api/trips')
    .set('Authorization', `Bearer ${token}`)
    .send({
      destination: 'Jaipur',
      days: 2,
      category: 'historical',
    })
    .expect(201);

  assert.equal(tripResponse.body.data.destination, 'Jaipur');
  assert.equal(tripResponse.body.data.itinerary.totalPlaces, 6);
  assert.equal(
    tripResponse.body.data.itinerary.generatedBy,
    'rule-based-city-routing',
  );

  const listResponse = await request(app)
    .get('/api/trips')
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  assert.equal(listResponse.body.data.length, 1);

  const anonymousListResponse = await request(app)
    .get('/api/trips')
    .expect(200);

  assert.equal(anonymousListResponse.body.data.length, 0);

  await request(app)
    .get(`/api/trips/${tripResponse.body.data.id}`)
    .expect(404);

  await request(app)
    .get(`/api/itineraries/${tripResponse.body.data.id}`)
    .expect(404);

  const itineraryResponse = await request(app)
    .get(`/api/itineraries/${tripResponse.body.data.id}`)
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  assert.equal(itineraryResponse.body.data.tripId, tripResponse.body.data.id);

  await request(app)
    .delete(`/api/trips/${tripResponse.body.data.id}`)
    .expect(404);

  await request(app)
    .delete(`/api/trips/${tripResponse.body.data.id}`)
    .set('Authorization', `Bearer ${token}`)
    .expect(204);
});

test('anonymous trips remain available without a token', async () => {
  const tripResponse = await request(app)
    .post('/api/trips')
    .send({
      destination: 'Jaipur',
      days: 1,
      category: 'family',
      budget: 0,
    })
    .expect(201);

  assert.equal(tripResponse.body.data.userId, null);
  assert.equal(tripResponse.body.data.budget, 0);

  const listResponse = await request(app)
    .get('/api/trips')
    .expect(200);

  assert.equal(listResponse.body.data.length, 1);
  assert.equal(listResponse.body.data[0].id, tripResponse.body.data.id);

  const itineraryResponse = await request(app)
    .get(`/api/itineraries/${tripResponse.body.data.id}`)
    .expect(200);

  assert.equal(itineraryResponse.body.data.totalPlaces, 3);

  await request(app)
    .delete(`/api/trips/${tripResponse.body.data.id}`)
    .expect(204);
});

test('city itinerary supplements sparse categories and balances days', async () => {
  const response = await request(app)
    .post('/api/itineraries/generate')
    .send({
      destination: 'Delhi',
      days: 2,
      category: 'historical',
    })
    .expect(200);

  assert.equal(response.body.data.destination, 'Delhi');
  assert.equal(response.body.data.destinationType, 'city');
  assert.ok(response.body.data.totalPlaces >= 3);
  assert.equal(response.body.data.days.length, 2);
  assert.equal(response.body.data.days[0].places[0].name, 'Qutub Minar');
});

test('state itinerary generation works when destination is a state', async () => {
  const response = await request(app)
    .post('/api/itineraries/generate')
    .send({
      destination: 'Kerala',
      days: 1,
      category: 'nature',
    })
    .expect(200);

  assert.equal(response.body.data.destination, 'Kerala');
  assert.equal(response.body.data.destinationType, 'state');
  assert.equal(response.body.data.totalPlaces, 3);
});
