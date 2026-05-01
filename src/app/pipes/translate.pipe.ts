import { ChangeDetectorRef, OnDestroy, Pipe, PipeTransform } from '@angular/core';
import { Subscription } from 'rxjs';
import { I18nService } from '../services/i18n.service';

@Pipe({
  name: 't',
  standalone: true,
  pure: false,
})
export class TranslatePipe implements PipeTransform, OnDestroy {
  private readonly subscription: Subscription;

  constructor(
    private readonly i18n: I18nService,
    private readonly cdr: ChangeDetectorRef
  ) {
    this.subscription = this.i18n.language$.subscribe(() => this.cdr.markForCheck());
  }

  transform(value: string): string {
    return this.i18n.translate(value);
  }

  ngOnDestroy(): void {
    this.subscription.unsubscribe();
  }
}
