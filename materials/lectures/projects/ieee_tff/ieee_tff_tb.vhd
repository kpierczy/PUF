library ieee;				-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;	-- dolaczenie calego pakietu 'STD_LOGIC_1164'

entity IEEE_TFF_TB is			-- pusty sprzeg projektu symulacji
end IEEE_TFF_TB;

architecture behavioural of IEEE_TFF_TB is -- cialo architektoniczne projektu
  signal R	:std_logic;		-- symulowane wejscie kasujace 'R'
  signal C	:std_logic;		-- symulowane wejscie zegarowe 'C'
  signal T	:std_logic;		-- symulowane wejscie sterujace 'T'
  signal Q	:std_logic;		-- obserwowane wyjscie danych 'Q'
begin					-- poczatek czesci wykonawczej architektury
  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    C <= '0'; wait for 5 ns;		-- przypisanie C='0' i odczekanie 5 ns
    C <= '1'; wait for 5 ns;		-- przypisanie C='1' i odczekanie 5 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    T <= '0'; wait for 40 ns;		-- przypisanie T='0' i odczekanie 40 ns
    T <= '1'; wait for 30 ns;		-- przypisanie T='1' i odczekanie 30 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    R <= '1'; wait for 120 ns;		-- przypisanie R='0' i odczekanie 120 ns
    R <= '0'; wait for 120 ns;		-- przypisanie R='1' i odczekanie 120 ns
  end process;				-- zakonczenie procesu

  ieee_tff_inst: entity work.IEEE_TFF(cialo) -- instancja projektu 'IEEE_TFF'
    port map (				-- mapowanie portow
      R => R,				-- przypisanie sygnalu 'R' do portu 'R'
      C => C,				-- przypisanie sygnalu 'C' do portu 'C'
      T => T,				-- przypisanie sygnalu 'T' do portu 'T'
      Q => Q				-- przypisanie sygnalu 'Q' do portu 'Q'
    );
end behavioural;			-- zakonczenie ciala architektonicznego
