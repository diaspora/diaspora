# language: es
Característica: adición
  Para evitar hacer errores tontos
  Como un matemático idiota
  Quiero saber la suma de los números

  Esquema del escenario: Sumar dos números
    Dado que he introducido <entrada_1> en la calculadora
    Y que he introducido <entrada_2> en la calculadora
    Cuando oprimo el <botón>
    Entonces el resultado debe ser <resultado> en la pantalla

  Ejemplos:
    | entrada_1 | entrada_2 | botón | resultado |
    | 20        | 30        | add   | 50        |
    | 2         | 5         | add   | 7         |
    | 0         | 40        | add   | 40        |