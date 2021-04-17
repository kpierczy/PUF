-- biblioteka STD jest wlaczana automatycznie do kazdego projektu

entity BNOR2 is			-- deklaracja sprzegu 'BNOR2'
 port (	A : in  bit;		-- deklaracja portu wejsciowego 'A'
        B : in  bit; 		-- deklaracja portu wejsciowego 'B'
        Y : out bit		-- deklaracja portu wyjsciowego 'Y'
      ); 			-- zakonczenie deklaracji listy portow
end entity BNOR2;		-- zakonczenie deklaracji sprzegu

architecture cialo of BNOR2 is	-- deklaracja ciala 'cialo' architektury
begin				-- poczatek czesci wykonawczej
  Y <= A nor B;			-- instrukcja czesci wykonawczej
end architecture cialo;		-- zakonczenie deklaracji ciala 'cialo'
