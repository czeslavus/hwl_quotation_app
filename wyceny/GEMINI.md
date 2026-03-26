# Projekt: Aplikacja do wycen międzynarodowych (HWL Quotation App)

## Cel projektu
Aplikacja służy do tworzenia wycen przejazdów międzynarodowych dla firmy transportowej oraz zarządzania zleceniami. Jest to typowa aplikacja internetowa (SPA) zbudowana w technologii Flutter/Dart.

## Priorytety i standardy
- **Wygląd i UX:** Priorytetem jest elegancki, profesjonalny wygląd oraz poprawne działanie we wszystkich popularnych przeglądarkach.
- **Wydajność:** Drugorzędna względem estetyki i poprawności logicznej.
- **Architektura:** Wzorzec **MVVM** z zachowaniem zasad **KISS**.
- **Lokalizacja (L10n):** Aplikacja musi być dwujęzyczna (PL/EN) z możliwością łatwego dodania kolejnych języków. Pliki tłumaczeń znajdują się w `lib/l10n`.

## Struktura projektu
Aplikacja jest podzielona na moduły (funkcjonalności) znajdujące się w katalogu `lib/features/`. Każdy moduł posiada następującą strukturę:
- `domain/`: Definicje interfejsów (repositories), modele danych (entities).
- `data/`: Implementacje repozytoriów, serwisy, źródła danych.
- `ui/`: ViewModele oraz widoki i widgety Fluttera.

## Integracja z API
- Źródłem prawdy dla komunikacji z backendem jest plik Swagger (OpenAPI) znajdujący się w: `api/portal openapi.v3.4.json`.
- W przypadku aktualizacji tego pliku przez użytkownika, należy zsynchronizować modele i serwisy w aplikacji.

## Główne moduły i Flow
1. **Wyceny (Quotations):** Tworzenie i przeglądanie ofert transportowych.
2. **Zlecenia (Orders):** Zarządzanie zleceniami powstałymi z wycen.
3. **Dodatki:** Widoki map, wizualizacja tras (`lib/features/route_by_postcode`).

**Standardowy przepływ:** Utworzenie wyceny -> Akceptacja (zmiana w zlecenie) LUB Odrzucenie wyceny.

## Wytyczne dla agenta AI
- Trzymaj się idiomatów Fluttera i Dart.
- Zachowuj czystość i elegancję architektury wewnątrz modułów `features`.
- Podczas wprowadzania zmian w kodzie, zawsze sprawdzaj i aktualizuj powiązane pliki lokalizacji (`.arb`).
- Jeśli zmieniasz logikę biznesową, upewnij się, że modele w `domain` są spójne z API.
- Projekt jest w fazie ciągłego rozwoju (development) – nie wdrażaj rozwiązań "na sztywno", jeśli można je zaprojektować elastycznie.
- Współpracuj zarówno w trybie CLI, jak i wewnątrz IntelliJ.
