entity PROCESS_SYNC is				-- deklaracja sprzegu PROCESS_SYNC'
  port ( R : in  bit;				-- deklaracja portu kasujacego 'R'
         S : in  bit; 				-- deklaracja portu ustawiajacego 'S'
         L : in  bit; 				-- deklaracja portu ladujacego 'L'
         E : in  bit; 				-- deklaracja portu zezwalajacego 'E'
         C : in  bit; 				-- deklaracja portu taktujacego 'C'
         D : in  bit;				-- deklaracja portu wej. danej 'D'
         Q : out bit	 			-- deklaracja portu wej. danej 'Q
       ); 					-- zakonczenie deklaracji listy portow
end PROCESS_SYNC;	 			-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_SYNC is		-- deklaracja ciala 'cialo' architektury
begin
  process (R, S, L, D, C, E) is			-- lista czulosci procesu
  begin						-- czesc wykonawcza procesu
    if (R='1') then				-- warunek dla sygnalu 'R'
      Q <= '0';					-- przypisanie stalej do wyjscia
    elsif (S='1') then				-- warunek dla sygnalu 'S'
      Q <= '1';					-- przypisanie stalej do wyjscia
    elsif (L='1') then				-- warunek dla sygnalu 'L'
      Q <= D;					-- przypisanie danej do wyjscia
    elsif  (C'event and C='1') then		-- warunek zbocza narastajacego 'C'
      if  (E='1') then				-- warunek zezwolenia na zapis
        Q <= D;					-- przypisanie danej do wyjscia
      end if;					-- zakonczenie instrukcji wyboru
    end if;					-- zakonczenie instrukcji wyboru
  end process;					-- zakonczenie procesu
end architecture cialo;				-- zakonczenie deklaracji ciala 'cialo'

