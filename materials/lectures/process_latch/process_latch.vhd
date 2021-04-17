entity PROCESS_LATCH is					-- deklaracja sprzegu PROCESS_LATCH'
  port (  ascii     : in  character;			-- deklaracja portu wejsciowego 'ascii'
          low_char  : out bit;	 	 		-- deklaracja portu wyjsciowego 'low_char'
          high_char : out bit;	 	 		-- deklaracja portu wyjsciowego 'high_char'
          digit     : out bit;		 		-- deklaracja portu wyjsciowego 'digit'
          control   : out bit		 		-- deklaracja portu wyjsciowego 'control'
       ); 						-- zakonczenie deklaracji listy portow
end PROCESS_LATCH;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_LATCH is			-- deklaracja ciala 'cialo' architektury

begin							-- poczatek czesci wykonawczej

  process (ascii) is					-- lista czulosci procesu
  begin							-- czesc wykonawcza procesu
       if ascii>='a' and ascii<='z' then low_char <= '1'; high_char <= '0'; digit <= '0'; control <= '0'; -- wybor malej liter
    elsif ascii>='A' and ascii<='Z' then low_char <= '0'; high_char <= '1'; digit <= '0'; control <= '0'; -- wybor du¿ej liter
    elsif ascii>='0' and ascii<='9' then low_char <= '0'; high_char <= '0'; digit <= '1'; control <= '0'; -- wybor liczby
    elsif ascii>=NUL and ascii<=USP then low_char <= '0'; high_char <= '0'; digit <= '0'; control <= '1'; -- wybor znaku kontrolnego
    end if;
  end process;						-- zakonczenie procesu

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'














--    else                                 low_char <= '0'; high_char <= '0'; digit <= '0'; control <= '0'; -- brak wyboru

















--architecture cialo of PROCESS_LATCH is			-- deklaracja ciala 'cialo' architektury
--
--begin							-- poczatek czesci wykonawczej
--
--  process (ascii) is					-- lista czulosci procesu
--  begin							-- czesc wykonawcza procesu
--    low_char  <= '0';					-- brak wyboru malej liter
--    high_char <= '0';					-- brak wyboru duzej liter
--    digit     <= '0';					-- brak wyboru cyfry
--    control   <= '0';					-- brak wyboru znaku kontrolnego
--       if ascii>='a' and ascii<='z' then low_char  <= '1'; -- wybor malej liter
--    elsif ascii>='A' and ascii<='Z' then high_char <= '1'; -- wybor du¿ej liter
--    elsif ascii>='0' and ascii<='9' then digit     <= '1'; -- wybor liczby
--    elsif ascii>=NUL and ascii<=USP then control   <= '1'; -- wybor znaku kontrolnego
--    end if;
--  end process;						-- zakonczenie procesu
--
--end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
