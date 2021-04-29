-- bibioteka STD jest wlaczana automatycznie do projektu
package pakiet is					-- deklaracja pakietu 'pakiet'
  constant ROZMIAR :natural := 4;			-- utworzenie stalej 'ROZMIAR' w ciele pakietu
end package pakiet;					-- zakonczenie pakietu

library ieee;						-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;			-- dolaczenie calego pakietu 'STD_LOGIC_1164'
library work;						-- opcjonalna klauzula dostepu do biblioteki 'work'
use     work.pakiet.all;				-- dolaczenie calego pakietu 'pakiet

entity PARAM_PAKIET is					-- deklaracja sprzegu 'PARAM_PAKIET'
  port (
    W		:in  std_logic_vector(0 to ROZMIAR-1);	-- wyjscie danych 'W'
    S1		:out natural range 0 to ROZMIAR;	-- wyjscie danych 'S1'
    S2		:out natural range 0 to ROZMIAR		-- wyjscie danych 'S2'
  );
end PARAM_PAKIET;

architecture cialo of PARAM_PAKIET is			-- deklaracja ciala 'cialo' architektury

  function sum(a :std_logic_vector) return natural is	-- deklaracja funkcji 'sum' z argumentem 'a'
    variable s :natural range 0 to a'length;		-- utworzenie zmiennej 's' w funkcji
  begin							-- czesc wykonawcza funkcji
    s := 0;						-- wyzerowanie sumy jedynek 's'
    for i in a'range loop				-- petla zmiennej 'i' po zakresie 'a'
      if a(i)='1' then					-- sprawdzenie, czy i-ty bit 'a' zawiera '1'
        s := s + 1;					-- zwiekszenie sumy jedynek 's' o 1
      end if;						-- zakonczenie instrukcji wyboru
    end loop;						-- zakonczenie petli
    return(s);						-- zwrocenie wartosci sumy jednyek 's'
  end function;

  signal S :std_logic_vector(W'high downto W'low);	-- utworzenie sygnalu 'S' wzgledem wektora 'W'

begin							-- poczatek czesci wykonawczej

  S1 <= sum(W(W'left+1 to W'right-1));			-- wywolanie funkcji 'sum' dla czesci wektora 'W'
  S  <= W;						-- podstawienie 'W' do sygnalu 'S'
  S2 <= sum(S);						-- wywolanie funkcji 'sum' dla calego wektora 'S'

end cialo;						-- zakonczenie ciala architektonicznego

