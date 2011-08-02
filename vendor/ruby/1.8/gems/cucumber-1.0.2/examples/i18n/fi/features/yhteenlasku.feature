# language: fi
Ominaisuus: Yhteenlasku
  Välttyäkseni hölmöiltä virheiltä
  Koska olen laskutaidoton
  Haluan että yhteenlaskut lasketaan puolestani

  Tapausaihio: Kahden luvun summa
    Oletetaan että olen syöttänyt laskimeen luvun <luku_1>
    Ja että olen syöttänyt laskimeen luvun <luku_2>
    Kun painan "<nappi>"
    Niin laskimen ruudulla pitäisi näkyä tulos <tulos>

  Tapaukset:
    | luku_1  | luku_2  | nappi  | tulos  |
    | 20      | 30      | summaa | 50     |
    | 2       | 5       | summaa | 7      |
    | 0       | 40      | summaa | 40     |
