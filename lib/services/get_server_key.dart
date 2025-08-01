import 'package:googleapis_auth/auth_io.dart';

class GetServerKey{
  Future<String> getServerKeyToken() async{
    final scopes = [
      // 'https://www.googleapis.com/auth/userinfo.email',
      // 'http://www.googleapis.com/auth/firebase.database',
      'https://www.googleapis.com/auth/firebase.messaging',
    ];

    final client = await clientViaServiceAccount(
        ServiceAccountCredentials.fromJson(
          {
            "type": "service_account",
            "project_id": "fuse-chat",
            "private_key_id": "2e420ed304bc82b01151f433c7348900b9204a03",
            "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQCccwYtUjuj0wXi\nTqM6qa0ddY996+RTaaQvlLXsHgYRYF72aMwpXnkHnSSi2eN0VmFZYYVsM5O8V8h+\ndwqN+wz6S691mVrKoz1CRyzBrxuvK3AxGPyju0xzBbd8OubQ+xz8jHnDNL7NbWmm\nShkFwdXpP2HEVx11P34vDMQUhWhcNCZuaD3pEKoILN5tCiBTYW4v84XqHWnbE5CJ\nPJCmJPdye9wHS85UsgGNIdbUoGwS8M1ueZcYIHH2TT1A/htYvg2gi7Wts+8hKvrg\ndOC2HCSn5HeXZDqZ0jhaNj06q/kxB8yyQOuF7CJlprbjJbVmyrhB9IEEEPdc1KxF\nHUNK8cFpAgMBAAECggEAGgxlviSHtRBk1agJsfH/1pyVCl59Cu1XLqvoOVrLYFfH\nH+hVe9rUtHGT4MB+CEf8l+zukdQpmC2WfoXz/i1LXR4+ZcpljUEuKSugFlSBO8J0\nANy77cf449rTEM5e0XNKAXujJ18QGLSLp2oFbgm2w8nvjYkCqNusNwm9WPxYYqdy\nYGB8cNedAa7MgiUH73T/OvZetebp2Rp5IEqnyn1mrjlrnRGEVdMSxDLK8VQO2jyo\no2GarHLQ+ufftd0WVstwKiCxj0X4rSuWT/8nUvt2JV1MDZs5GLcCTuKCf7Q753Qx\nA8aTswxrgisRVMtDnbyDMsmBIgMCGvxNqjsHMoK9bQKBgQDXKhVkEYH5WcLkonAJ\nk6QguOgH07Zmfehbj3jDm3Oh8GYm/S4PATNSB9HjMD98DhQDjrFF/I0X1owDwBYX\nQTkW9ujWicHJwx0nAsk2cP3l6ZP0ETzn744duOCNPKPys4wLYLXRLgmMgDv5HGH3\njBTobU6J9GznPGhcdJJ6I3dBdQKBgQC6JDn2kW/st393pKQj1ykzcqHC/2biVJ2X\nXVmXXxbGcLopFuA6qgDeSKWTM/ospBp251BKEXVS3pDr8qNUTUAMRkVMkyTpKEx+\nALLUradHCPr1oO2EKE030vD46+h9xeA0NSLIzUTnNbFS1rvBWZoBm5Yl/o1YHGDS\n+OVzyOctpQKBgQCuErj9nYB22FzpllVoGg9V/eKSuoC+CK0crkU4k6KIaDJs5rYF\no6X+fp8a26Tw237rpdzbz0fi+kuKmTQGGllyr82ODCNA9V63efSJ2/49rKxrcCrD\nRjbG6xSYj2/gYcwyREq0cjd9eR2MG59So/0iUZSR3bLhnSidbB45PEo2JQKBgQCR\nOBwEcjiorAwFEmyADad2HNN4pvrkTnFYGpr/zk6daGrEDbXH7sOYp4KNkjp2Q1zm\nMNZhwrcOfNcBTR4Bcfcq3FPKRu2//RGYKAFcjVH4yFfJ88/5j9uWVrpq6NlL7mlZ\nMa8+i25bF3eNEjwOv1G4OWLtp2csO4+KaGXSbAV3hQKBgQCb5Z4PsLjFjAug7gjw\nn8IlVYEVX1Of+j52BD4HclZfRMTR11u2j/PVw4HuDFESKqsTaUx4c1NAl4BLG3aR\ndlU45suClJ2i0Sc6drdmIkoZVRLRkEW2M1sT05KkE4b10IKXv4tIxSBMbngRh4pk\npKl5fLX5KiUfXtz6hp2xBI7iOA==\n-----END PRIVATE KEY-----\n",
            "client_email": "fuse-chat@fuse-chat.iam.gserviceaccount.com",
            "client_id": "109796113218129475328",
            "auth_uri": "https://accounts.google.com/o/oauth2/auth",
            "token_uri": "https://oauth2.googleapis.com/token",
            "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
            "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/fuse-chat%40fuse-chat.iam.gserviceaccount.com",
            "universe_domain": "googleapis.com"
          },
        ),
        scopes,
    );
    final accessServerKey = client.credentials.accessToken.data;
    return accessServerKey;
  }
}