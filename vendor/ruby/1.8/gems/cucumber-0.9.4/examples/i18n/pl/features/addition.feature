# language: pl
Właściwość: Dodawanie
  W celu uniknięcia głupich błędów
  Jako matematyczny idiota
  Chcę sprawdzić wartość sumy dwóch liczb

  Szablon scenariusza: Dodaj dwie liczby
    Zakładając wprowadzenie do kalkulatora liczby <liczba_1>
    Oraz wprowadzenie do kalkulatora liczby <liczba_2>
    Jeżeli nacisnę <przycisk>
    Wtedy rezultat <wynik> wyświetli się na ekranie

  Przykłady:
    | liczba_1 | liczba_2 | przycisk | wynik  |
    | 20       | 30       | dodaj    | 50     |
    | 2        | 5        | dodaj    | 7      |
    | 0        | 40       | dodaj    | 40     |
