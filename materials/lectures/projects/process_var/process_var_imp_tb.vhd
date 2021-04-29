library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PROCESS_VAR_IMP_TB is				-- pusty sprzeg projektu symulacji
end PROCESS_VAR_IMP_TB;

architecture behavioural of PROCESS_VAR_IMP_TB is 	-- cialo architektoniczne projektu

  signal A	:STD_LOGIC_VECTOR ( 2 downto 0 ) := (others => '0'); -- symulowane wejscie A
  signal Y1	:STD_LOGIC_VECTOR ( 2 downto 0 );	-- obserwowane wyjscie Y1
  signal Y2	:STD_LOGIC_VECTOR ( 2 downto 0 );	-- obserwowane wyjscie Y1

begin							-- poczatek czesci wykonawczej architektury

  process is						-- proces bezwarunkowy
  begin							-- czesc wykonawcza procesu
    wait for 10 ns; A <= A + 1;			 	-- odczekanie 10 ns i zwiekszenie A o 1
  end process;						-- zakonczenie procesu

  process_var_inst: entity work.PROCESS_VAR(Structure) 	-- instancja projektu 'PROCESS_VAR2'
    port map (						-- mapowanie portow
      A  => A,						-- przypisanie sygnalu 'A' do portu 'A'
      Y1 => Y1,						-- przypisanie sygnalu 'Y1' do portu 'Y1'
      Y2 => Y2						-- przypisanie sygnalu 'Y2' do portu 'Y2'
    );

end behavioural;					-- zakonczenie ciala architektonicznego	
