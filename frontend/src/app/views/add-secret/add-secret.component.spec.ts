import { async, ComponentFixture, TestBed } from '@angular/core/testing';

import { AddSecretComponent } from './add-secret.component';

describe('AddSecretComponent', () => {
  let component: AddSecretComponent;
  let fixture: ComponentFixture<AddSecretComponent>;

  beforeEach(async(() => {
    TestBed.configureTestingModule({
      declarations: [ AddSecretComponent ]
    })
    .compileComponents();
  }));

  beforeEach(() => {
    fixture = TestBed.createComponent(AddSecretComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
