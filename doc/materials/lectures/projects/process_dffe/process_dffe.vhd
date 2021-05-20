entity PROCESS_DFFE is				-- deklaracja sprzegu PROCESS_DFFE'
  port ( R : in  bit;				-- deklaracja portu kasujacego 'R'
         C : in  bit; 				-- deklaracja portu taktujacego 'C'
         E : in  bit; 				-- deklaracja portu zezwalajacego 'E'
         D : in  bit;				-- deklaracja portu wej. danej 'D'
         Q : out bit	 			-- deklaracja portu wej. danej 'Q
       ); 					-- zakonczenie deklaracji listy portow
end PROCESS_DFFE;	 			-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_DFFE is		-- deklaracja ciala 'cialo' architektury
begin
  process (R, C) is				-- lista czulosci procesu
  begin						-- czesc wykonawcza procesu
    if (R='1') then				-- warunek dla sygnalu 'R'
      Q <= '0';					-- przypisanie stalej do wyjscia
    elsif  (C'event and C='1') then		-- warunek zbocza narastajacego 'C'
      if  (E='1') then				-- warunek zezwolenia na zapis
        Q <= D;					-- przypisanie danej do wyjscia
      end if;					-- zakonczenie instrukcji wyboru
    end if;					-- zakonczenie instrukcji wyboru
  end process;					-- zakonczenie procesu
end architecture cialo;				-- zakonczenie deklaracji ciala 'cialo'
