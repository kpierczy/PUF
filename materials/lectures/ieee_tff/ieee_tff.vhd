library ieee;				-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;	-- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity IEEE_TFF is			-- deklaracja sprzegu IEEE_TFF'
  port (
    R		:in  std_logic;		-- wejscie kasujace 'R'
    C		:in  std_logic;		-- wejscie zegarowe 'C'
    T		:in  std_logic;		-- wejscie sterujace 'T'
    Q		:out std_logic		-- wyjscie danych 'Q'
  );
end IEEE_TFF;

architecture cialo of IEEE_TFF is	-- deklaracja ciala 'cialo' architektury

  signal M	:std_logic;		-- element pamietajacy na basie sygnalu 'M'

begin					-- poczatek czesci wykonawczej

  process (R,C) is			-- lista czulosci procesu
  begin					-- czesc wykonawcza procesu
    if (R='0') then			-- warunek kasowania dla sygnalu 'R'='0'
      M <= '0';				-- przypisanie stalej '0' do sygnalu 'R'
    elsif (C'event and C='1') then	-- warunek dla zbocza narastajacego 'C'
      if (T='1') then			-- warunek sygnalu zezwolenia ;T'='1'
        M <= not(M);			-- przypisanie sygnalu zenegowanego 'M'
      end if;				-- zakonczenie instrukcji wyboru
    end if;				-- zakonczenie instrukcji wyboru
  end process;				-- zakonczenie procesu
  Q <= M;				-- przypisanie do portu 'Q' sygnalu 'M'

end cialo;				-- zakonczenie deklaracji ciala 'cialo'

