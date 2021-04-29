library ieee;						-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;			-- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity IEEE_COMP1_TB is					-- pusty sprzeg projektu symulacji
end IEEE_COMP1_TB;

architecture behavioural of IEEE_COMP1_TB is		-- cialo architektoniczne projektu

  signal D1		:std_logic_vector(7 downto 0);	-- symulowane wejscie danych 'D1'
  signal D2		:std_logic_vector(7 downto 0);	-- symulowane wejscie danych 'D2'
  signal SU, SS, AU, AS	:std_logic;			-- obserwowane wyjscia relacji 'R'

begin							-- poczatek czesci wykonawczej

  process is						-- proces bezwarunkowy
  begin							-- czesc wykonawcza procesu
    D1 <= (others => '1');				-- ustawienie bitow danej 'D1' na '1' (NB: 255, U2: -1)
    D2 <= (others => '0');				-- ustawienie bitow danej 'D2' na '0' (NB:   0, U2:  0)
    wait for 10 ns;					-- odczekanie 10 ns
    D1 <= (others => '0');				-- ustawienie bitow danej 'D1' na '0' (NB:   0, U2:  0)
    D2 <= (others => '1');				-- ustawienie bitow danej 'D2' na '1' (NB: 255, U2: -1)
    wait for 10 ns;					-- odczekanie 10 ns
  end process;						-- zakonczenie procesu

  ieee_comp1_inst: entity work.IEEE_COMP1(cialo)	-- instancja projektu 'IEEE_COMP1'
    port map (D1 => D1, D2 => D2, R => SU);		-- przypisanie portom sygnalow

  ieee_comp2_inst: entity work.IEEE_COMP2(cialo)	-- instancja projektu 'IEEE_COMP2'
    port map (D1 => D1, D2 => D2, R => SS);		-- przypisanie portom sygnalow

  ieee_comp3_inst: entity work.IEEE_COMP3(cialo)	-- instancja projektu 'IEEE_COMP3'
    port map (D1 => D1, D2 => D2, R => AU);		-- przypisanie portom sygnalow

  ieee_comp4_inst: entity work.IEEE_COMP4(cialo)	-- instancja projektu 'IEEE_COMP4'
    port map (D1 => D1, D2 => D2, R => AS);		-- przypisanie portom sygnalow

end behavioural;

