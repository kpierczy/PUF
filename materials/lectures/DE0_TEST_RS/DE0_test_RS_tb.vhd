library ieee;						-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;			-- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity DE0_TEST_RS_TB is				-- pusty sprzeg projektu symulacji 'DE0_TEST_RS_TB'
end DE0_TEST_RS_TB;

architecture cialo_tb of DE0_TEST_RS_TB is		-- cialo architektoniczne projektu 'cialo_tb'

  constant F_ZEGARA	:natural := 50_000_000;		-- czestotliwosc zegara systemowego w [Hz]
  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;	-- okres zegara systemowego
  signal   R		:std_logic := '0';		-- symulowany sygnal resetujacacy
  signal   C		:std_logic := '1';		-- symulowany zegar taktujacy inicjowany na '1'

begin

  process is						-- proces bezwarunkowy
  begin							-- czesc wykonawcza procesu
    R <= '0'; wait for 100 ns;				-- ustawienie sygnalu 'res' na '1' i odczekanie 100 ns
    R <= '1'; wait;					-- ustawienie sygnalu 'res' na '0' i zatrzymanie
  end process;						-- zakonczenie procesu

  process is						-- proces bezwarunkowy
  begin							-- czesc wykonawcza procesu
    C <= not(C); wait for O_ZEGARA/2;			-- zanegowanie sygnalu 'clk' i odczekanie pol okresu zegara
  end process;						-- zakonczenie procesu

end cialo_tb;			        		-- zakonczenie ciala architektonicznego 'cialo_tb'
