import { haversineDistanceKm } from '../../utils/distance.js';
import {
  AVERAGE_CITY_SPEED_KMH,
  STOP_BUFFER_MINUTES,
  TRAVEL_STYLE_CONFIG,
} from './plannerConfig.js';
import { estimateVisitMinutes } from './dayAssigner.js';

function parseClockTime(value) {
  const match = /^(\d{1,2}):(\d{2})$/.exec(String(value || ''));

  if (!match) {
    return null;
  }

  const hours = Number(match[1]);
  const minutes = Number(match[2]);

  if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
    return null;
  }

  return hours * 60 + minutes;
}

function formatClockTime(totalMinutes) {
  const minutesInDay = 24 * 60;
  const normalized = ((Math.round(totalMinutes) % minutesInDay) + minutesInDay) % minutesInDay;
  const hours = Math.floor(normalized / 60);
  const minutes = normalized % 60;

  return `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
}

function estimateTravelMinutes(distanceKm) {
  if (distanceKm === 0) {
    return 0;
  }

  return Math.max(
    5,
    Math.round((distanceKm / AVERAGE_CITY_SPEED_KMH) * 60 + STOP_BUFFER_MINUTES),
  );
}

function nextArrivalAfterOpening(arrival, place) {
  const openingMinutes = parseClockTime(place.openingTime);

  if (openingMinutes === null) {
    return arrival;
  }

  if (arrival < openingMinutes) {
    return openingMinutes;
  }

  return arrival;
}

export function scheduleDays(days, input) {
  const styleConfig = TRAVEL_STYLE_CONFIG[input.travelStyle];

  return days.map((day) => {
    let cursor = styleConfig.dayStartMinutes;

    const places = day.places.map((place, index) => {
      const previousPlace = day.places[index - 1];
      const travelDistanceKm = previousPlace
        ? haversineDistanceKm(
            previousPlace.latitude,
            previousPlace.longitude,
            place.latitude,
            place.longitude,
          )
        : 0;
      const estimatedTravelMinutes = estimateTravelMinutes(travelDistanceKm);
      const estimatedVisitMinutes = estimateVisitMinutes(place.category, input.travelStyle);
      const arrivalMinutes = nextArrivalAfterOpening(cursor + estimatedTravelMinutes, place);
      const departureMinutes = arrivalMinutes + estimatedVisitMinutes;

      cursor = departureMinutes;

      return {
        placeId: place.id,
        name: place.name,
        category: place.category,
        sequenceOrder: index + 1,
        estimatedVisitMinutes,
        estimatedTravelMinutes,
        travelDistanceKm: Number(travelDistanceKm.toFixed(2)),
        openingTime: place.openingTime,
        closingTime: place.closingTime,
        latitude: place.latitude,
        longitude: place.longitude,
        arrivalTime: formatClockTime(arrivalMinutes),
        departureTime: formatClockTime(departureMinutes),
        score: Number((place.score || 0).toFixed(4)),
        clusterId: place.clusterId,
      };
    });

    return {
      dayNumber: day.dayNumber,
      places,
    };
  });
}
