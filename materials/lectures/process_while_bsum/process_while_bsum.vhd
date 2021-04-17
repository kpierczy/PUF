entity PROCESS_WHILE_BSUM is				-- deklaracja sprzegu PROCESS_WHILE_BSUM'
  port (  A : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A1'
          Y : out natural range 0 to 2	 		-- deklaracja portu wyjsciowego 'Y'
       ); 						-- zakonczenie deklaracji listy portow
end PROCESS_WHILE_BSUM;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_WHILE_BSUM is		-- deklaracja ciala 'cialo' architektury

begin							-- poczatek czesci wykonawczej

  process (A) is					-- lista czulosci procesu
    variable P : natural range 0 to 4;			-- utworzenie zmiennej 'P'
    variable L : natural range 0 to 2;			-- utworzenie zmiennej 'L'
  begin							-- czesc wykonawcza procesu
    P := 0;						-- ustawienie wartosci poczatkowej 'P'
    L := 0;						-- ustawienie wartosci poczatkowej 'L'
    while P<4 and L<2 loop				-- petla od 0 do 3 dla identyfikatora 'P'
      if (A(P)='1') then				-- badanie, czy bit o indeksie 'P' ma wartosc '1'
        L := L + 1;					-- zwiekszenie o 1 liczniaka bitow '1'
      end if;						-- zakonczenie warunku
      P := P + 1;					-- zwiekszenie o 1 liczniaka bitow '1'
    end loop;						-- zakonczenie petli
    Y <= L;						-- przypisanie stanu 'L' do sygnalu 'Y'
  end process;						-- zakonczenie procesu

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
