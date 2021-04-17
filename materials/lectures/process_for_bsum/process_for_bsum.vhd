entity PROCESS_FOR_BSUM is				-- deklaracja sprzegu PROCESS_FOR_BSUM'
  port (  A : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A'
          Y : out natural range 0 to 2	 		-- deklaracja portu wyjsciowego 'Y'
       ); 						-- zakonczenie deklaracji listy portow
end PROCESS_FOR_BSUM;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_FOR_BSUM is		-- deklaracja ciala 'cialo' architektury

begin							-- poczatek czesci wykonawczej

  process (A) is					-- lista czulosci procesu
    variable L : natural range 0 to 2;			-- utworzenie zmienna 'L'
  begin							-- czesc wykonawcza procesu
    L := 0;						-- ustawienie wartosci poczatkowej 'L' na 0
    for P in 0 to A'length-1 loop			-- petla po kolejnych bitach identyfikatora 'P'
      next when A(P)='0';				-- warunkowy powrot do petli
      L := L + 1;					-- zwiekszenie o 2^P licznika 'L'
      exit when L=2;					-- warunkowe opuszczenie petli
    end loop;						-- zakonczenie petli
    Y <= L;						-- przypisanie stanu 'L' do sygnalu 'Y'
  end process;						-- zakonczenie procesu

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
