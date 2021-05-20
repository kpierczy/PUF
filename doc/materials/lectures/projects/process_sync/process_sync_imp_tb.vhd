library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PROCESS_SYNC_IMP_TB is		-- pusty sprzeg projektu symulacji
end PROCESS_SYNC_IMP_TB;

architecture behavioural of PROCESS_SYNC_IMP_TB is -- cialo architektoniczne projektu
 
  signal R : STD_LOGIC;			-- symulowane wejscie kasuj¹ce 'R'
  signal S : STD_LOGIC; 		-- symulowane wejscie ustawiaj¹ce 'S'
  signal L : STD_LOGIC; 		-- symulowane wejscie ladujace 'L'
  signal E : STD_LOGIC; 		-- symulowane wejscie zezwalajace 'E'
  signal C : STD_LOGIC; 		-- symulowane wejscie taktujace 'C'
  signal D : STD_LOGIC := '0';		-- symulowane wejscie danej 'D'
  signal Q : STD_LOGIC;	 		-- obserwowane wyjscie danej 'Q

begin					-- poczatek czesci wykonawczej architektury

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    R <= '1'; wait for 20 ns;		-- przypisanie R='1' i odczekanie 20 ns
    R <= '0'; wait for 200 ns;		-- przypisanie R='0' i odczekanie 200 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    S <= '0'; wait for 300 ns;		-- przypisanie S='0' i odczekanie 300 ns
    S <= '1'; wait for 20 ns;		-- przypisanie S='1' i odczekanie 20 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    L <= '0'; wait for 200 ns;		-- przypisanie L='0' i odczekanie 100 ns
    L <= '1'; wait for 50 ns;		-- przypisanie L='1' i odczekanie 40 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    E <= '0'; wait for 10 ns;		-- przypisanie E='0' i odczekanie 10 ns
    E <= '1'; wait for 20 ns;		-- przypisanie E='1' i odczekanie 10 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    C <= '0'; wait for 5 ns;		-- przypisanie C='0' i odczekanie 5 ns
    C <= '1'; wait for 5 ns;		-- przypisanie C='1' i odczekanie 5 ns
  end process;				-- zakonczenie procesu

  process is				-- proces bezwarunkowy
  begin					-- czesc wykonawcza procesu
    D <= not(D); wait for 3 ns;		-- przypisanie negacji wartoœci D i odczekanie 3 ns
    D <= not(D); wait for 3 ns;		-- przypisanie negacji wartoœci D i odczekanie 3 ns
    D <= not(D); wait for 4 ns;		-- przypisanie negacji wartoœci D i odczekanie 4 ns
  end process;				-- zakonczenie procesu

  process_sync_inst: entity work.PROCESS_SYNC(Structure) -- instancja projektu 'PROCESS_SYNC'
    port map (				-- mapowanie portow
      R => R,				-- przypisanie sygnalu 'R' do portu 'R'
      S => S,				-- przypisanie sygnalu 'S' do portu 'S'
      L => L,				-- przypisanie sygnalu 'L' do portu 'L'
      E => E,				-- przypisanie sygnalu 'E' do portu 'E'
      C => C,				-- przypisanie sygnalu 'C' do portu 'C'
      D => D,				-- przypisanie sygnalu 'D' do portu 'D'
      Q => Q				-- przypisanie sygnalu 'Q' do portu 'Q'
    );

end behavioural;			-- zakonczenie ciala architektonicznego
