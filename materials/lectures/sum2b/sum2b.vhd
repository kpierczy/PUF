-- bibioteka STD jest wlaczana automatycznie do projektu

entity SUM2B is				-- deklaracja sprzegu 'SUM2B'
 port (	A : in  bit;			-- deklaracja portu wejsciowego 'A'
        B : in  bit;			-- deklaracja portu wejsciowego 'B'
        S : out bit;			-- deklaracja portu wyjsciowego 'Y'
        P : out bit			-- deklaracja portu wyjsciowego 'P'
      ); 				-- zakonczenie deklaracji listy portow
end SUM2B; 				-- zakonczenie deklaracji sprzegu

architecture cialo of SUM2B is		-- deklaracja ciala 'cialo' architektury

begin					-- poczatek czesci wykonawczej

  S <= A xor B;				-- wyznaczenie m³odszego bitu sumy
  P <= A and B;				-- wyznaczenie starszego bitu sumy (przeniesienie)
  
end architecture cialo;			-- zakonczenie deklaracji ciala 'cialo'
