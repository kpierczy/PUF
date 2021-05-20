entity PROCEDURE_OPTREG2 is				-- deklaracja sprzegu PROCEDURE_OPTREG2'
  generic ( ASYN : boolean := FALSE);			-- deklaracja i ustawienie parametru 'ASYN'
  port ( R : in  bit;					-- deklaracja portu kasujacego 'R'
         C : in  bit; 					-- deklaracja portu taktujacego 'C'
         E : in  bit; 					-- deklaracja portu zezwalajacego 'E'
         A : in  bit_vector(3 downto 0);		-- deklaracja portu wejsciowego 'A'
         Y : out natural range 0 to 2	 		-- deklaracja portu wyjsciowego 'Y'
       ); 						-- zakonczenie deklaracji listy portow
end PROCEDURE_OPTREG2;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCEDURE_OPTREG2 is		-- deklaracja ciala 'cialo' architektury
begin							-- poczatek czesci wykonawczej

  process (R, C, A) is					-- lista czulosci procesu
    procedure exec is					-- utworzenie procedury 'exec'
      variable L : natural range 0 to 2;		-- utworzenie zmienna 'L'
    begin						-- czesc wykonawcza procedury
      L := 0;						-- ustawienie wartosci poczatkowej 'L' na 0
      for P in 0 to A'length-1 loop			-- petla po kolejnych bitach identyfikatora 'P'
        next when A(P)='0';				-- warunkowy powrot do petli
        L := L + 1;					-- zwiekszenie o 2^P licznika 'L'
        exit when L=2;					-- warunkowe opuszczenie petli
      end loop;						-- zakonczenie petli
      Y <= L;						-- przypisanie stanu 'L' do sygnalu 'Y'
    end procedure;					-- zakonczenie procedury
  begin							-- czesc wykonawcza procesu
    if (not(ASYN)) then					-- warunek dla 'ASYN=FALSE'
     exec;						-- wywolanie procedury 'exec'
    elsif (R='1') then					-- warunek dla sygnalu 'R'
      Y <= 0;						-- przypisanie stalej do wyjscia
    elsif  (C'event and C='1') then			-- warunek zbocza narastajacego 'C'
      if  (E='1') then					-- warunek zezwolenia na zapis
        exec;						-- wywolanie procedury 'exec'
      end if;						-- zakonczenie instrukcji wyboru
    end if;						-- zakonczenie instrukcji wyboru
  end process;						-- zakonczenie procesu

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'

--------------------------------------------------------

entity PROCEDURE_OPTREG2_IMPL is			-- deklaracja sprzegu PROCEDURE_OPTREG2_IMPL'
  port ( R1, R2 : in  bit;				-- deklaracja portow kasujacych 'R1' i 'R2'
         C1, C2 : in  bit; 				-- deklaracja portow taktujacych 'C1' i 'C2'
         E1, E2 : in  bit; 				-- deklaracja portow zezwalajacych 'E1' i 'E2'
         A1, A2 : in  bit_vector(3 downto 0);		-- deklaracja portow wejsciowych 'A1' i 'A2'
         Y1, Y2 : out natural range 0 to 2		-- deklaracja portow wyjsciowych 'Y1' i 'Y2'
       ); 						-- zakonczenie deklaracji listy portow
end PROCEDURE_OPTREG2_IMPL;	 			-- zakonczenie deklaracji naglowka

architecture cialo of PROCEDURE_OPTREG2_IMPL is		-- deklaracja ciala 'cialo' architektury
begin							-- poczatek czesci wykonawczej

  procedure_optreg2f_inst: entity work.PROCEDURE_OPTREG2(cialo) -- instancja projektu 'PROCEDURE_OPTREG2'
    generic map (ASYN => FALSE)				-- mapowanie generic
    port map (R=>R1, C=>C1, E=>E1, A=>A1, Y=>Y1);	-- mapowanie portow

  procedure_optreg2t_inst: entity work.PROCEDURE_OPTREG2(cialo) -- instancja projektu 'PROCEDURE_OPTREG2'
    generic map (ASYN => TRUE)				-- mapowanie generic
    port map (R=>R2, C=>C2, E=>E2, A=>A2, Y=>Y2);	-- mapowanie portow

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
