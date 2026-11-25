# Bacheca annunci di lavoro: front-end (Flutter)

App Flutter per una bacheca di annunci di lavoro. Le aziende registrate pubblicano
annunci e consultano le candidature; i candidati, senza registrarsi, rispondono
compilando un form e allegando il curriculum in PDF.

Questo repository contiene **solo il front-end**. Il server (API e dati) è in un
repository separato:

- Back-end: `<LINK_REPOSITORY_BACKEND>`

## Funzionalità

| Attore | Funzione |
|---|---|
| Azienda | registrazione, login, logout |
| Azienda | pubblicazione di un annuncio |
| Azienda | elenco dei propri annunci, candidature ricevute, apertura del curriculum |
| Candidato | consultazione della bacheca e del dettaglio di un annuncio |
| Candidato | candidatura con nome, cognome, email e curriculum PDF |

Il login dell'azienda resta salvato sul dispositivo, e annunci e candidature sono
conservati dal server, quindi i dati restano disponibili dopo la chiusura dell'app.

## Requisiti

- Flutter SDK e Android Studio
- Un emulatore Android, uno smartphone Android o Chrome
- Il back-end in esecuzione (vedi il suo README)

## Avvio

1. Avvia il back-end seguendo le istruzioni del suo repository.
2. Scarica le dipendenze:
   ```
   flutter pub get
   ```
3. Avvia l'app con **Run** da Android Studio, oppure:
   ```
   flutter run
   ```

### Indirizzo del server

L'app sceglie un indirizzo predefinito in base alla piattaforma:

| Dove gira l'app | Indirizzo predefinito |
|---|---|
| Emulatore Android | `http://10.0.2.2:8000` |
| Chrome | `http://localhost:8000` |
| Smartphone reale | da impostare (vedi sotto) |

Per uno **smartphone reale**: PC e telefono devono essere sulla stessa rete Wi-Fi.
Trova l'IP del PC con `ipconfig`, poi nell'app tocca l'icona ingranaggio in alto nella
bacheca e scrivi `http://IP_DEL_PC:8000`. L'indirizzo resta salvato sul telefono.

## Struttura del codice

```
lib/
├── main.dart                  avvio dell'app
├── config.dart                indirizzo del server (salvato sul dispositivo)
├── models.dart                classi Job e Application
├── api_service.dart           chiamate al server e gestione della sessione
├── ui.dart                    componenti di supporto
└── screens/
    ├── job_list_screen.dart           bacheca pubblica
    ├── job_detail_screen.dart         dettaglio annuncio
    ├── apply_screen.dart              form di candidatura con PDF
    ├── company_auth_screen.dart       registrazione e login azienda
    ├── company_home_screen.dart       area riservata, logout
    ├── new_job_screen.dart            nuovo annuncio
    ├── applications_screen.dart       candidature di un annuncio
    ├── application_detail_screen.dart dati del candidato, apertura del PDF
    └── server_settings_dialog.dart    cambio indirizzo del server
```

## Librerie principali

`http`, `file_picker`, `shared_preferences`, `open_filex`, `path_provider`, `url_launcher`.

## Note

- L'accesso al server in HTTP è abilitato in `android/app/src/main/AndroidManifest.xml`
  (`usesCleartextTraffic`), perché il server gira in locale senza HTTPS.
- Il curriculum si apre con l'app PDF di sistema su Android e in una nuova scheda su Chrome.
  Se sull'emulatore non è installato nessun lettore PDF, installane uno dal Play Store.
