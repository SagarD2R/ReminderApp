import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:googleapis_auth/auth_io.dart' as auth;

class PushNotificationService {
  static Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "reminder-9481e",
      "private_key_id": "92d53140badbafeb1f9803a7d0d6e7f2f4071db4",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCGt34bBi4nvn1w\nenHAMJWcQ2whXzTdr3dFmbN6ncJY0r32UcKVUalDLYK4fkuRPA95gwpyioGvoV3s\nrlbzWhr8DLMnDCXWb+rMCbIJDKTLKKqFHux0DVMrisfE1VqyUUD89Ljo7uSTWaTd\nJq4RbDjtshZt3EP+RjOH1QSHvkQkurJAItVJuSHyX/eKf5y6IyfZeN/9fYukMey9\nvX6vRk4MnZ6RqUlbtNHx5Es729Ll6fYGHLOfi8E68CRnpXrH04b6xsBNejA4ZVzO\n3IYV2BTH758U72vQpWKUgDYxLJT7ZLi7SI2SH0Y/kzbANfovtrnwweUmyWemMDGc\nA+6PN+zRAgMBAAECggEAAmi9pJYTtTo+3AgUiK9VvZmnEWG2fFBq/Z+mCgdQNm5u\nXz1PEYSIVl81+z6m803zqOSjBzFa6F0mZNkpTOjLmr5PZd9dvdv6gvOZb3f+anOr\nuP24lMq4NgshT2/RU2cIln154RCEne34eMv8SOt6iSWqKQTLYny25zL0BcltRorZ\niNAyXIT3IXZP/T7mQbeIsb61ScdeVdK5a34rjckUI+dJ4XFE08islJUxaKL81JmP\nBMXauIrekDupxkCS8HTFbGVgZWNPHRqOEeA4ukzHVKFzze6gun/fxUYJ98v+xbqQ\ncpS5gvqjjtXZJFx8nbycsH/rKwKtL8grx+5Z5SJ2wQKBgQC527A1eBQUktT7vrRl\nVPDfFetWahjqSEX/+E2J/BjiD20kYYUIcDG3LQT0fnjA8LiE47VhKvxtpkRFR8mZ\nrl8P4luRnSaR0W4G58uCBrthn3ZSyOr1wqduMEUrpZZfXaTD+9R/LUxN9y1LGPD7\nPHKI7s7Ojz4h0INUaeP4dk36zQKBgQC5juHEW9buQ0TE2SRxzMcp54GEOiFUNh7E\nGIfBKP3R/+9uq4WdTeofvJ8fS7eAIvp7HBjMQKm7v977ifCWm7PWE3BAbtyu6ajh\nmo1jnhK7lmQ71KkDWd/Al2KGNmg2/LGASv4VcsVPVTJgP9CT3ucMEYswKe0WHeXA\nVzql08/CFQKBgEEPGu6MmxLclzuMdR9njW26AYhdWV1hcUd6BsJ/gcJYPg9XJ7dd\ndrm1Q5/GScTYPu8dupdJ8dT8N7e8umBWfqZTyVP+m8q9cfNu3nkknCE/La8q77yZ\np/xVX1E5BJtbb1q/Y5IlLCm6lZtNHsYDUeCHH9OEpu41TFOXQZru5rsdAoGAESnk\nPDN6iAN04vhq5JPagEfHtSFjX9S5t83FENrnz3rq/MOk0k4Yr+LUnSJ10MZrgOOy\nb4IzsQgoaf/yXxv74Htf0LXwd8VpN6UCGwrOFMfucZJUJ9kyVzApjtyNeziYepN1\nOSqqkZIB3OFKO8NMf9NHmqbmJTuSut3WsOwMtZkCgYEAuOO1aAxZY6Hi0w5r7pzP\nx0MHNoRH1rzUe0jAt2wzamCrisbP3ambpa8AcCyNjShQITlPqVs+vACITVgMG45H\njy/lkbvzmpN1RivFusGz4BR30lb0lEr6AWAmrKHJkPBcpaPpaJAyeiJYj/P4qdZX\nUwZKdOhrvnkHPtdTsY1CXqM=\n-----END PRIVATE KEY-----\n",
      "client_email": "flutter-reminder@reminder-9481e.iam.gserviceaccount.com",
      "client_id": "117606434789815078437",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-reminder%40reminder-9481e.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes, client);

    client.close();

    return credentials.accessToken.data;
  }

  static sendNotificationToSelectedDriver(String deviceToken, BuildContext context) async {
    final String serverAccessToken = await getAccessToken();
    String endPointFirebaseCloudMessaging = "https://fcm.googleapis.com/v1/projects/reminder-9481e/messages:send";

    final Map<String, dynamic> message = {
      'message': {
        "token": deviceToken,
        "notification": {'title': "Hi User", "body": "This is testing message"},
        "data":{
          "title":"mytitle",
          "body":"mybody",
          "url":"myurl"
        },

      }
    };
    final http.Response response = await http.post(Uri.parse(endPointFirebaseCloudMessaging),
        headers: <String, String>{'Content-Type': 'application/json', 'Authorization': 'Bearer $serverAccessToken'}, body: jsonEncode(message));

    if (response.statusCode == 200) {
      print('Notification sent');
    } else {
      print('Notifcation Failed');
    }
  }
}
