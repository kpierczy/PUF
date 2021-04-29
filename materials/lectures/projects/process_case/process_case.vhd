entity PROCESS_CASE is					-- deklaracja sprzegu PROCESS_CASE'
  port (  ascii     : in  character;			-- deklaracja portu wejsciowego 'ascii'
          low_char  : out bit;	 			-- deklaracja portu wyjsciowego 'low_char'
          high_char : out bit;	 			-- deklaracja portu wyjsciowego 'high_char'
          digit     : out bit;	 			-- deklaracja portu wyjsciowego 'digit'
          control   : out bit	 			-- deklaracja portu wyjsciowego 'control'
       ); 						-- zakonczenie deklaracji listy portow
end PROCESS_CASE;	 				-- zakonczenie deklaracji naglowka

architecture cialo of PROCESS_CASE is			-- deklaracja ciala 'cialo' architektury

begin							-- poczatek czesci wykonawczej

  process (ascii) is					-- lista czulosci procesu
  begin							-- czesc wykonawcza procesu
    low_char  <= '0';					-- brak wyboru malej liter
    high_char <= '0';					-- brak wyboru duzej liter
    digit     <= '0';					-- brak wyboru cyfry
    control   <= '0';					-- brak wyboru znaku kontrolnego
    case ascii is					-- sekcejny wybor sygnalem 'ascii'
      when 'a' to 'z' => low_char  <= '1';		-- wybor malej liter
      when 'A' to 'Z' => high_char <= '1';		-- wybor duzej liter
      when '0' to '9' => digit     <= '1';		-- wybor cyfry
      when NUL to USP => control   <= '1';		-- wybor znaku kontrolnego
      when others     => null;				-- instrukcja pusta
    end case;
  end process;						-- zakonczenie procesu

end architecture cialo;					-- zakonczenie deklaracji ciala 'cialo'
