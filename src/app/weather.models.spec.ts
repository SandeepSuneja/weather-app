import { LocationOption, locationsMatch } from './weather.models';

describe('locationsMatch', () => {
  it('matches when both ids are equal', () => {
    const a: LocationOption = { id: 1, name: 'A', country: 'X', latitude: 1, longitude: 2 };
    const b: LocationOption = { id: 1, name: 'B', country: 'Y', latitude: 9, longitude: 9 };
    expect(locationsMatch(a, b)).toBeTrue();
  });

  it('matches coordinates when ids differ or one id missing', () => {
    const a: LocationOption = { id: 1, name: 'A', country: 'X', latitude: 10, longitude: 20 };
    const b: LocationOption = { name: 'B', country: 'Y', latitude: 10.0005, longitude: 20.0005 };
    expect(locationsMatch(a, b)).toBeTrue();
  });

  it('returns false when ids differ and coordinates differ', () => {
    const a: LocationOption = { id: 1, name: 'A', country: 'X', latitude: 10, longitude: 20 };
    const b: LocationOption = { id: 2, name: 'B', country: 'Y', latitude: 50, longitude: 60 };
    expect(locationsMatch(a, b)).toBeFalse();
  });
});
