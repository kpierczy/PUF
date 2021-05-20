library ieee;						-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;			-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.numeric_std.all;				-- dolaczenie calego pakietu 'NUMERIC_STD'

entity IEEE_COMP3 is					-- deklaracja sprzegu IEEE_COMP3'
  port (
    D1		:in  std_logic_vector(7 downto 0);	-- wejscie danych 'D1'
    D2		:in  std_logic_vector(7 downto 0);	-- wejscie danych 'D2'
    R		:out std_logic				-- wyjscie relacji 'R'
  );
end IEEE_COMP3;

architecture cialo of IEEE_COMP3 is			-- deklaracja ciala 'cialo' architektury

begin							-- poczatek czesci wykonawczej

  R <= '1' when (UNSIGNED(D1)>UNSIGNED(D2)) else '0';	-- operacja relacji miedzy 'D1' i 'D2'

end cialo;						-- zakonczenie ciala architektonicznego

