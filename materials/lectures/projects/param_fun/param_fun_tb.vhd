library ieee;					-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;		-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;		-- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'

entity PARAM_FUN_TB is				-- pusty sprzeg projektu symulacji
end PARAM_FUN_TB;

architecture behavioural of PARAM_FUN_TB is	-- cialo architektoniczne projektu

  signal  W	:std_logic_vector(0 to 3);	-- symulowane wejscie danych 'W'
  signal  S1	:natural range 0 to 4;		-- obserwowane wyjscie danych 'S1'
  signal  S2	:natural range 0 to 4;		-- obserwowane wyjscie danych 'S2'

begin						-- poczatek czesci wykonawczej

  process is					-- proces bezwarunkowy
  begin						-- czesc wykonawcza procesu
    W <= (others =>'0');			-- wyzerowanie wektora 'W'
    for i in 0 to 2**W'length-1 loop		-- petla po wartosciach wektora 'W'
      wait for 10 ns;				-- odczekanie 20 ns
      W <= W + 1;				-- zwiekszenie wektora 'W' o 1
    end loop;					-- zakonczenie petli
  end process;					-- zakonczenie procesu

  param_fun_inst: entity work.PARAM_FUN(cialo) -- instancja projektu 'PARAM_FUN'
    port map (					-- mapowanie portow
      W => W,					-- przypisanie sygnalu 'W' do portu 'W'
      S1 => S1,					-- przypisanie sygnalu 'S1' do portu 'S1'
      S2 => S2					-- przypisanie sygnalu 'S2' do portu 'S2'
   );

end behavioural;				-- zakonczenie ciala architektonicznego

