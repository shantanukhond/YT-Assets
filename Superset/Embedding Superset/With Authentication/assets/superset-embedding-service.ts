import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable, catchError, switchMap, throwError } from 'rxjs';


import { embedDashboard } from '@superset-ui/embedded-sdk';

@Injectable({
  providedIn: 'root'
})
export class SupersetEmbedService {

  private supersetUrl = 'http://SUPERSET_IP_ADDRESS'
  private supersetApiUrl = `${this.supersetUrl}/api/v1/security`
  private dashboardId = "YOUR_DASHBOARD_EMBEDDING_ID"

  constructor(private http: HttpClient) { }

  getToken() {
    //calling login to get access token
    const body = {
      "password": "embedding-admin",
      "provider": "db",
      "refresh": true,
      "username": "embedding-admin"
    };

    const headers = new HttpHeaders({
      "Content-Type": "application/json"
    });

    return this.http.post(`${this.supersetApiUrl}/login`, body, { headers }).pipe(
      catchError((error) => {
        console.error(error);
        return throwError(error);
      }),
      switchMap((accessToken: any) => {
        const body = {
          "resources": [
            {
              "type": "dashboard",
              "id": this.dashboardId,
            }
          ],
          "rls":[],
          "user": {
            "username": "report-viewer",
            "first_name": "report-viewer",
            "last_name": "report-viewer",
          }
        };

        const acc = accessToken["access_token"]; 
          const headers = new HttpHeaders({
          "Content-Type": "application/json",
          "Authorization": `Bearer ${acc}`,
        });

        return this.http.post<any>(`${this.supersetApiUrl}/guest_token/`, body, { headers });
      }));
  }




  embedDashboard() {
    return new Observable((observer) => {
      this.getToken().subscribe(
        (token) => {
          embedDashboard({
            id: this.dashboardId,
            supersetDomain: this.supersetUrl,
            mountPoint: document.getElementById('superset_embedding_div_class')!,
            fetchGuestToken: () => token["token"],
            dashboardUiConfig: {
              hideTitle: true,
              hideChartControls: true,
              hideTab: true,
              filters: {
                visible: false,
                expanded: false
              },
              urlParams: {
                standalone: "1",
                show_filters: "0",
                show_native_filters: "0"

              }
            },
          });
          observer.next();
          observer.complete();
        },
        (error) => {
          observer.error(error);
        }
      );
    });
  }
}
