entity PROCESS_FOR_CONV is				-- deklaracja sprzegu PROCESS_FOR_CONV'
  port (  A : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A1'
          Y : out natural range 0 to 15 		-- deklaracja portu wyjsciowego 'Y'
       ); 						-- zakonczenie deklaracji listy portow
end PROCESS_FOR_CONV;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_FOR_CONV is		-- deklaracja ciala 'cialo' architektury

begin							-- poczatek czesci wykonawczej

  process (A) is					-- lista czulosci procesu
    variable L : natural range 0 to 15;			-- utworzenie zmienna 'L'
  begin							-- czesc wykonawcza procesu
    L := 0;						-- ustawienie wartosci poczatkowej 'L' na 0
    for P in 0 to 3 loop				-- petla od 0 do 3 dla identyfikatora 'P'
      if (A(P)='1') then				-- badanie, czy bit o indeksie 'P' ma wartosc '1'
        L := L + 2**P;					-- zwiekszenie o 2^P licznika 'L'
      end if;						-- zakonczenie warunku
    end loop;						-- zakonczenie petli
    Y <= L;						-- przypisanie stanu 'L' do sygnalu 'Y'
  end process;						-- zakonczenie procesu

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
