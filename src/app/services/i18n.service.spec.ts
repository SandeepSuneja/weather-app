import { TestBed } from '@angular/core/testing';
import { I18nService } from './i18n.service';

describe('I18nService', () => {
  let service: I18nService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(I18nService);
    document.documentElement.lang = 'en';
    document.documentElement.dir = 'ltr';
  });

  it('should translate known keys for en', () => {
    service.setLanguage('en');
    expect(service.translate('app.title')).toBe('Weatherly');
  });

  it('should translate for hi and ja', () => {
    service.setLanguage('hi');
    expect(service.translate('app.language')).toBe('भाषा');
    service.setLanguage('ja');
    expect(service.translate('app.language')).toBe('言語');
  });

  it('setLanguage updates document and dir stays ltr', () => {
    service.setLanguage('ja');
    expect(document.documentElement.lang).toBe('ja');
    expect(document.documentElement.dir).toBe('ltr');
  });

  it('falls back to en then key for unknown translation', () => {
    service.setLanguage('ja');
    expect(service.translate('nonexistent.key.xyz')).toBe('nonexistent.key.xyz');
  });

  it('falls back to English when active locale has no entry', () => {
    service.setLanguage('ja');
    expect(service.translate('__coverage.enOnly')).toBe('fallback-en');
  });

  it('exposes supportedLanguages', () => {
    expect(service.supportedLanguages).toEqual(['en', 'hi', 'ja']);
  });

  it('language$ emits on setLanguage', (done) => {
    const seen: string[] = [];
    const sub = service.language$.subscribe((l) => seen.push(l));
    service.setLanguage('hi');
    service.setLanguage('en');
    sub.unsubscribe();
    expect(seen).toContain('hi');
    expect(seen).toContain('en');
    done();
  });
});
