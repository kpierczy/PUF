library ieee;				-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;	-- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity IEEE_AND_TB is			-- pusty sprzeg projektu symulacji
end IEEE_AND_TB;

architecture behavioural of IEEE_AND_TB is -- cialo architektoniczne projektu

  signal I1	:std_logic;		-- symulowane wejscie 'I1'
  signal I2	:std_logic;		-- symulowane wejscie 'I2'
  signal O	:std_logic;		-- obserwowane wyjscie 'O'

begin					-- czesc wykonawcza ciala projektu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    for f1 in std_logic loop		-- petla zmiennej 'f1' po elementach typu 'std_logic'
      I1 <= f1;				-- przypisnie zmiennej 'f1' do sygnalu 'I1'
      for f2 in std_logic loop		-- petla zmiennej 'f2' po elementach typu 'std_logic'
        I2 <= f2;			-- przypisnie zmiennej 'f2' do sygnalu 'I2'
        wait for 10 ns;			-- odczekanie 10 ns
      end loop;				-- zakonczenie petli dla zmiennej 'f2'
    end loop;				-- zakonczenie petli dla zmiennej 'f1'
  end process;				-- zakonczenie procesu

  ieee_and_inst: entity work.IEEE_AND(cialo) -- instancja projektu 'IEEE_AND'
    port map (				-- mapowanie portow
      I1 => I1,				-- przypisanie sygnalu 'I1' do portu 'I1'
      I2 => I2,				-- przypisanie sygnalu 'I2' do portu 'I2'
      O  => O				-- przypisanie sygnalu 'O' do portu 'O'
    );
end behavioural;			-- zakonczenie ciala architektonicznego