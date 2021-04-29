library ieee;				-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;		-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;		-- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

entity IEEE_REDUCE_TB is			-- pusty sprzeg projektu symulacji
end IEEE_REDUCE_TB;

architecture behavioural of IEEE_REDUCE_TB is	-- cialo architektoniczne projektu

  signal A :std_logic_vector(7 downto 0) := (others => '0'); -- symulowane wejscie A z inicjalizacja
  signal Y :std_logic;				-- obserwowane wyjscie

begin

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    wait for 10 ns;			-- odczekanie 10 ns
    A <= A + 1;				-- przypisanie sygnalowi 'A' wartosci o 1 wiekszej
  end process;				-- zakonczenie procesu

  IEEE_REDUCE_inst: entity work.IEEE_REDUCE(cialo)	-- instancja projektu 'BBUF'
    port map (				-- mapowanie portow
      A => A,				-- przypisanie sygnalu 'A' do portu 'A'
      Y => Y				-- przypisanie sygnalu 'Y' do portu 'Y'
    );
end behavioural;			-- zakonczenie ciala architektonicznego