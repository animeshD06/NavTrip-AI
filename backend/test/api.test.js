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

test('health endpoint allows loopback web origins in development', async () => {
  const response = await request(app)
    .get('/api/health')
    .set('Origin', 'http://localhost:61977')
    .expect(200);

  assert.equal(response.headers['access-control-allow-origin'], 'http://localhost:61977');
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

test('advanced guide pack, narration, recommendation, assistant, weather, and optimizer APIs work', async () => {
  const guidePacksResponse = await request(app)
    .get('/api/guide-packs')
    .query({ city: 'Jaipur' })
    .expect(200);

  assert.equal(guidePacksResponse.body.data[0].city, 'Jaipur');

  const manifestResponse = await request(app)
    .post('/api/guide-packs/Jaipur/download-manifest')
    .send({ language: 'en-IN' })
    .expect(200);

  assert.ok(manifestResponse.body.data.checksum);
  assert.ok(manifestResponse.body.data.narrations.length > 0);

  const narrationResponse = await request(app)
    .get('/api/narrations/place_hawa_mahal')
    .query({ mode: 'short' })
    .expect(200);

  assert.equal(narrationResponse.body.data.placeId, 'place_hawa_mahal');

  const hiddenGemsResponse = await request(app)
    .get('/api/recommendations/hidden-gems')
    .query({ city: 'Jaipur', interests: 'historical,nature' })
    .expect(200);

  assert.ok(hiddenGemsResponse.body.data.length > 0);
  assert.ok(hiddenGemsResponse.body.data[0].reasons.length > 0);

  const assistantResponse = await request(app)
    .post('/api/assistant/query')
    .send({ city: 'Jaipur', query: 'What should I visit nearby?' })
    .expect(200);

  assert.equal(assistantResponse.body.data.mode, 'offline-local-search');
  assert.ok(assistantResponse.body.data.sources.length > 0);

  const optimizerResponse = await request(app)
    .post('/api/itineraries/optimize')
    .send({
      destination: 'Jaipur',
      days: 2,
      interests: ['historical'],
      travelStyle: 'balanced',
      groupSize: 2,
      budget: 5000,
    })
    .expect(200);

  assert.equal(optimizerResponse.body.data.generatedBy, 'deterministic-route-optimizer');
  assert.equal(optimizerResponse.body.data.optimizedRoute.days.length, 2);

  const insightsResponse = await request(app)
    .get('/api/weather-crowd/insights')
    .query({ city: 'Jaipur' })
    .expect(200);

  assert.ok(insightsResponse.body.data.weather.summary);
  assert.ok(insightsResponse.body.data.crowdPredictions.length > 0);
});

test('advanced authenticated community, gamification, social, and analytics APIs work', async () => {
  const email = `advanced-${Date.now()}@example.com`;
  const registerResponse = await request(app)
    .post('/api/auth/register')
    .send({
      name: 'Advanced API Test',
      email,
      password: 'password123',
    })
    .expect(201);
  const token = registerResponse.body.data.token;

  const routeResponse = await request(app)
    .post('/api/routes')
    .set('Authorization', `Bearer ${token}`)
    .send({
      title: 'Jaipur Heritage Walk',
      description: 'A compact route for old-city highlights.',
      attractions: ['place_hawa_mahal', 'place_city_palace_jaipur'],
      budget: 2000,
      durationDays: 1,
      difficulty: 'easy',
      tags: ['heritage', 'family'],
    })
    .expect(201);

  assert.equal(routeResponse.body.data.status, 'draft');

  const routeId = routeResponse.body.data.id;

  await request(app)
    .post(`/api/routes/${routeId}/publish`)
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  const likedResponse = await request(app)
    .post(`/api/routes/${routeId}/like`)
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  assert.equal(likedResponse.body.data.likedByMe, true);

  await request(app)
    .post(`/api/routes/${routeId}/bookmark`)
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  await request(app)
    .post(`/api/routes/${routeId}/comments`)
    .set('Authorization', `Bearer ${token}`)
    .send({ body: 'Great route idea.' })
    .expect(201);

  const ratedResponse = await request(app)
    .post(`/api/routes/${routeId}/ratings`)
    .set('Authorization', `Bearer ${token}`)
    .send({ rating: 5 })
    .expect(200);

  assert.equal(ratedResponse.body.data.stats.averageRating, 5);

  const trendingResponse = await request(app)
    .get('/api/routes/trending')
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  assert.equal(trendingResponse.body.data[0].id, routeId);

  const achievementResponse = await request(app)
    .post('/api/achievements/events')
    .set('Authorization', `Bearer ${token}`)
    .send({
      eventType: 'route_completed',
      entityType: 'community_route',
      entityId: routeId,
    })
    .expect(201);

  assert.ok(achievementResponse.body.data.xp > 0);

  const storyResponse = await request(app)
    .post('/api/stories')
    .set('Authorization', `Bearer ${token}`)
    .send({
      title: 'Pink City Morning',
      body: 'Started early and avoided the crowd.',
      routeId,
    })
    .expect(201);

  assert.equal(storyResponse.body.data.title, 'Pink City Morning');

  const feedResponse = await request(app)
    .get('/api/social/feed')
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  assert.equal(feedResponse.body.data[0].story.id, storyResponse.body.data.id);

  const analyticsResponse = await request(app)
    .post('/api/analytics/events')
    .set('Authorization', `Bearer ${token}`)
    .send({
      sessionId: 'test-session',
      feature: 'voiceTour',
      eventName: 'narration_started',
      entityType: 'place',
      entityId: 'place_hawa_mahal',
      metadata: { mode: 'short' },
    })
    .expect(201);

  assert.equal(analyticsResponse.body.data.feature, 'voiceTour');

  const adminAnalyticsResponse = await request(app)
    .get('/api/admin/analytics')
    .set('Authorization', `Bearer ${token}`)
    .expect(200);

  assert.ok(adminAnalyticsResponse.body.data.totalEvents >= 1);
});
