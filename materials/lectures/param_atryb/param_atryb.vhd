library ieee;					-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;		-- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity PARAM_ATRYB is				-- deklaracja sprzegu 'PARAM_ATRYB'
  port (
    W		:in  std_logic_vector(0 to 3);	-- wejscie danych 'W'
    S		:out natural range 0 to 4	-- wyjscie danych 'S'
  );
end PARAM_ATRYB;

architecture cialo of PARAM_ATRYB is		-- deklaracja ciala 'cialo' architektury

begin						-- poczatek czesci wykonawczej

  process (W) is				-- lista czulosci procesu
    variable N :natural range 0 to W'length; 	-- deklaracja zmiennej 'N'
  begin						-- czesc wykonawcza procesu
    N := 0;					-- podstawienie licznika jedynek N=0
    for i in W'range loop			-- petla zmiennej 'i' po zakresie 'W'
      if W(i)='1' then				-- sprawdzenie, czy i-ty bit 'W' zawiera '1'
        N := N + 1;				-- zwiekszenie licznika jedynek 'N' o 1
      end if;					-- zakonczenie instrukcji wyboru
    end loop;					-- zakonczenie petli
    S <= N;					-- podstawienie pod sygnal 'S' wartosci 'N'
  end process;					-- zakonczenie procesu

end cialo;					-- zakonczenie ciala architektonicznego

