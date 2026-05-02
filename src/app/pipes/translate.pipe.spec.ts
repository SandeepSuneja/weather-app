import { ChangeDetectorRef } from '@angular/core';
import { TestBed } from '@angular/core/testing';
import { TranslatePipe } from './translate.pipe';
import { I18nService } from '../services/i18n.service';

describe('TranslatePipe', () => {
  let i18n: I18nService;
  let pipe: TranslatePipe;
  let cdr: jasmine.SpyObj<ChangeDetectorRef>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [I18nService],
    });
    i18n = TestBed.inject(I18nService);
    cdr = jasmine.createSpyObj<ChangeDetectorRef>('ChangeDetectorRef', ['markForCheck']);
    pipe = new TranslatePipe(i18n, cdr);
    i18n.setLanguage('en');
  });

  it('transform returns translation', () => {
    expect(pipe.transform('app.title')).toBe('Weatherly');
  });

  it('ngOnDestroy unsubscribes', () => {
    const spy = spyOn(pipe['subscription'], 'unsubscribe');
    pipe.ngOnDestroy();
    expect(spy).toHaveBeenCalled();
  });
});
