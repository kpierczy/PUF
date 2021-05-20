entity PROCESS_VAR is			-- deklaracja sprzegu PROCESS_VAR'
  port ( A : in  natural range 0 to 7;	-- deklaracja portu wejsciowego 'A'
        Y1 : out natural range 0 to 7; 	-- deklaracja portu wyjsciowego 'Y1'
        Y2 : out natural range 0 to 7 	-- deklaracja portu wyjsciowego 'Y2'
       ); 				-- zakonczenie deklaracji listy portow
end PROCESS_VAR;	 		-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_VAR is	-- deklaracja ciala 'cialo' architektury
  signal S :natural range 0 to 7 := 3; -- deklaracja sygnalu 'S'
begin					-- poczatek czesci wykonawczej

  process (A) is			-- lista czulosci procesu
     variable Z :natural range 0 to 7 := 5; -- deklaracja zmiennej 'Z'
  begin					-- czesc wykonawcza procesu
    i1: S  <= A;			-- przypisanie sygnalu do sygnalu (z etykieta)
    i2: S  <= (S + 1) mod 8;		-- przypisanie wyrazenia do sygnalu (z etykieta)
    i3: Y1 <= S;			-- przypisanie sygnalu do sygnalu (z etykieta)
    i4: Z  := A;			-- przypisanie sygnalu do zmiennej (z etykieta)
    i5: Z  := (Z + 1) mod 8;		-- przypisanie wyrazenia do zmiennej (z etykieta)
    i6: Y2 <= Z;			-- przypisanie zmiennej do sygnalu (z etykieta)
  end process;				-- zakonczenie procesu

end architecture cialo;			-- zakonczenie deklaracji ciala 'cialo'
