import { Component, ElementRef } from '@angular/core';
import { SupersetEmbedService } from './superset-embed.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.scss']
})
export class AppComponent {

  constructor(private embedService: SupersetEmbedService) {
    this.embedService.embedDashboard().subscribe(
      (res) => {
        console.log(res);
      },
      (error) => {
        console.error(error);
      }
    );
  }
}

