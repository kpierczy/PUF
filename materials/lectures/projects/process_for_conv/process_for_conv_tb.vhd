entity PROCESS_FOR_CONV_TB is			-- pusty sprzeg projektu symulacji
end PROCESS_FOR_CONV_TB;

architecture behavioural of PROCESS_FOR_CONV_TB is -- cialo architektoniczne projektu

  signal A	:bit_vector(3 downto 0);	-- symulowane wejscie A
  signal Y	:natural range 0 to 4;		-- obserwowane wyjscie Y
	
begin						-- czesc wykonawcza ciala projektu

  process is					-- proces bezwarunkowy
  begin						-- czesc wykonawcza procesu
    A <= "0000"; wait for 10 ns;		-- ustawienie sygnalu 'A'=0 i odczekanie 10 ns
    A <= "0001"; wait for 10 ns;		-- ustawienie sygnalu 'A'=1 i odczekanie 10 ns
    A <= "0010"; wait for 10 ns;		-- ustawienie sygnalu 'A'=2 i odczekanie 10 ns
    A <= "0011"; wait for 10 ns;		-- ustawienie sygnalu 'A'=3 i odczekanie 10 ns
    A <= "0100"; wait for 10 ns;		-- ustawienie sygnalu 'A'=4 i odczekanie 10 ns
    A <= "0101"; wait for 10 ns;		-- ustawienie sygnalu 'A'=5 i odczekanie 10 ns
    A <= "0110"; wait for 10 ns;		-- ustawienie sygnalu 'A'=6 i odczekanie 10 ns
    A <= "0111"; wait for 10 ns;		-- ustawienie sygnalu 'A'=7 i odczekanie 10 ns
    A <= "1000"; wait for 10 ns;		-- ustawienie sygnalu 'A'=8 i odczekanie 10 ns
    A <= "1001"; wait for 10 ns;		-- ustawienie sygnalu 'A'=9 i odczekanie 10 ns
    A <= "1010"; wait for 10 ns;		-- ustawienie sygnalu 'A'=10 i odczekanie 10 ns
    A <= "1011"; wait for 10 ns;		-- ustawienie sygnalu 'A'=11 i odczekanie 10 ns
    A <= "1100"; wait for 10 ns;		-- ustawienie sygnalu 'A'=12 i odczekanie 10 ns
    A <= "1101"; wait for 10 ns;		-- ustawienie sygnalu 'A'=13 i odczekanie 10 ns
    A <= "1110"; wait for 10 ns;		-- ustawienie sygnalu 'A'=14 i odczekanie 10 ns
    A <= "1111"; wait for 10 ns;		-- ustawienie sygnalu 'A'=15 i odczekanie 10 ns
  end process;					-- zakonczenie procesu


  process_for_conv_inst: entity work.PROCESS_FOR_CONV(cialo) -- instancja projektu 'PROCESS_FOR_CONV'
    port map (A => A, Y => Y);			-- przypisanie portom sygnalow

end behavioural;				-- zakonczenie ciala architektonicznego
