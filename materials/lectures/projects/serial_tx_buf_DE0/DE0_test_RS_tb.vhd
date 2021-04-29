library ieee;							-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;				-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_unsigned.all;				-- dolaczenie calego pakietu 'STD_LOGIC_UNSIGNED'
use     ieee.std_logic_misc.all;				-- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity DE0_TEST_RS_TB is					-- pusty sprzeg projektu symulacji 'DE0_TEST_RS_TB'
end DE0_TEST_RS_TB;

architecture cialo_tb of DE0_TEST_RS_TB is			-- cialo architektoniczne projektu 'cialo_tb'

  constant F_ZEGARA	:natural := 50_000_000;			-- czestotliwosc zegara systemowego w [Hz]
  constant O_ZEGARA	:time := 1 sec/F_ZEGARA;		-- okres zegara systemowego
  signal   R		:std_logic := '0';			-- symulowany sygnal resetujacacy
  signal   C		:std_logic := '1';			-- symulowany zegar taktujacy inicjowany na '1'

  constant L_BODOW	:natural := 5_000_000;			-- predkosc nadawania w [bodach]
  constant B_SLOWA	:natural := 8;				-- liczba bitow slowa danych (5-8)
  constant B_PARZYSTOSCI:natural := 1;				-- liczba bitow parzystosci (0-1)
  constant B_STOPOW	:natural := 2;				-- liczba bitow stopu (1-2)
  constant N_TX		:boolean := TRUE;			-- negacja logiczna sygnalu szeregowego
  constant N_SLOWO	:boolean := TRUE;			-- negacja logiczna slowa danych

  constant O_BITU	:time := 1 sec/L_BODOW;			-- okres czasu trwania jednego bodu
  signal   TX		:std_logic;				-- obserwowane wyjscie 'TX'
  signal   SLOWO	:std_logic_vector(B_SLOWA-1 downto 0);	-- symulowane wejscie 'SLOWO'
  signal   NADAJ	:std_logic;				-- symulowane wejscie 'NADAJ'
  signal   WYSYLANIE	:std_logic;				-- obserwowane wyjscie 'WYSYLANIE'
  signal   ODEBRANO	:std_logic_vector(SLOWO'range);		-- testowe slowo 'ODEBRANO'

begin

  process is							-- proces bezwarunkowy
  begin								-- czesc wykonawcza procesu
    R <= '0'; wait for 100 ns;					-- ustawienie sygnalu 'R' na '1' i odczekanie 100 ns
    R <= '1'; wait;						-- ustawienie sygnalu 'R' na '0' i zatrzymanie
  end process;							-- zakonczenie procesu

  process is							-- proces bezwarunkowy
  begin								-- czesc wykonawcza procesu
    C <= not(C); wait for O_ZEGARA/2;				-- zanegowanie sygnalu 'C' i odczekanie pol okresu zegara
  end process;							-- zakonczenie procesu

  process is							-- proces bezwarunkowy
  begin								-- czesc wykonawcza procesu
    NADAJ  <= '0';						-- ustawienie sygnalu 'NADAJ' na '0'
    SLOWO  <= (others=>'0');					-- ustawienie bitow sygnalu 'SLOWO' na '0'
    wait for 200 ns;						-- odczekanie 200 ns
    loop							-- rozpoczecie petli nieskonczonej
      NADAJ  <= '1';						-- ustawienie sygnalu 'NADAJ' na '1'
      wait for O_ZEGARA;					-- odczekanie 1 okresu zegara
      NADAJ  <= '0';						-- ustawienie sygnalu 'NADAJ' na '0'
      wait until WYSYLANIE='0';					-- oczekiwanie na wartosc '0' sygnalu 'WYSYLANIE'
      SLOWO <= SLOWO + 7;					-- zwiekszenia wartosci 'SLOWO' o 7
      wait for 2*O_ZEGARA;					-- odczekanie 2 okresow zegara
    end loop;							-- zakonczenie petli
  end process;							-- zakonczenie procesu

  SERIAL_TX_BUF_INST: entity work.SERIAL_TX_BUF			-- instancja odbirnika szeregowego 'SERIAL_TX_BUF'
    generic map(						-- mapowanie parametrow biezacych
      F_ZEGARA             => F_ZEGARA,				-- czestotliwosc zegata w [Hz]
      L_BODOW              => L_BODOW,				-- predkosc odbierania w [bodach]
      B_SLOWA              => B_SLOWA,				-- liczba bitow slowa danych (5-8)
      B_PARZYSTOSCI        => B_PARZYSTOSCI,			-- liczba bitow parzystosci (0-1)
      B_STOPOW             => B_STOPOW,				-- liczba bitow stopu (1-2)
      N_TX                 => N_TX,				-- negacja logiczna sygnalu szeregowego
      N_SLOWO              => N_SLOWO				-- negacja logiczna slowa danych
    )
    port map(							-- mapowanie sygnalow do portow
      R                    => R,				-- sygnal resetowania
      C                    => C,				-- zegar taktujacy
      TX                   => TX,				-- odebrany sygnal szeregowy
      SLOWO                => SLOWO,				-- nadawane slowo danych
      NADAJ                => NADAJ,				-- flaga zadania nadawania
      WYSYLANIE            => WYSYLANIE				-- flaga wykonywania procesu nadawania
    );

  process is							-- proces bezwarunkowy
    function neg(V :std_logic; N :boolean) return std_logic is	-- deklaracja funkcji wewnetrznej 'neg'
    begin							-- czesc wykonawcza funkcji wewnetrznej
      if (N=FALSE) then return (V); end if;			-- zwrot wartosc 'V' gdy 'N'=FALSE
      return (not(V));						-- zwrot zanegowanej wartosci 'V'
    end function;						-- zakonczenie funkcji wewnetrznej
    variable blad   : boolean;					-- deklaracja zmiennej 'blad'
  begin								-- czesc wykonawcza procesu
    ODEBRANO <= (others => '0');				-- ustawienie bitow sygnalu 'ODEBRANO' na '0'
    loop							-- rozpoczecie petli nieskonczonej
      blad := FALSE;						-- ustawienie zmiennej 'blad' na 'FALSE'
      wait until neg(TX,N_TX)='1';				-- oczekiwanie na bit START
      wait for O_BITU/2;					-- odczekanie polowy bodu
      if (neg(TX,N_TX) /= '1') then				-- badanie niezgodnosci zmodyfikowanego 'TX' z wartoscia '1'
        blad := TRUE;						-- ustawienie zmiennej 'blad' na 'TRUE'
      end if;							-- zakonczenie instukcji warunkowej
      for i in 0 to B_SLOWA-1 loop				-- petla po liczbie bitow slowa danych
        wait for O_BITU;					-- odczekanie jednego bodu
        ODEBRANO(ODEBRANO'left-1 downto 0) <= ODEBRANO(ODEBRANO'left downto 1); -- przesuniecie w prawo bitow sygnalu 'ODEBRANO'
        ODEBRANO(ODEBRANO'left) <= neg(neg(TX,N_TX),N_SLOWO);	-- przypodanie do najstarszego bitu 'ODEBRANO' zmodyfikowanego 'TX'
      end loop;							-- zakonczenie petli
      if (B_PARZYSTOSCI = 1) then				-- badanie aktywowania bitu parzystosci
        wait for O_BITU;					-- odczekanie jednego bodu
        if (neg(neg(TX,N_TX),N_SLOWO) /= XOR_REDUCE(SLOWO)) then -- badanie niezgodnosci oczekwanej wartosci bitu parzystosci
          blad := TRUE;						-- ustawienie zmiennej 'blad' na 'TRUE'
        end if;							-- zakonczenie instukcji warunkowej
      end if;							-- zakonczenie instukcji warunkowej
      for i in 0 to B_STOPOW-1 loop				-- petla po liczbie bitow STOP
        wait for O_BITU;					-- odczekanie jednego bodu
        if (neg(TX,N_TX) /= '0') then				-- badanie niezgodnosci zmodyfikowanego 'TX' z wartoscia '0'
          blad := TRUE;						-- ustawienie zmiennej 'blad' na 'TRUE'
        end if;							-- zakonczenie instukcji warunkowej
      end loop;							-- zakonczenie petli
      if (blad=TRUE) then					-- badanie stanu 'TRUE' zmiennej 'blad'
        ODEBRANO <= (others => 'X');				-- ustawienie bitow sygnalu 'ODEBRANO' na 'X'
      end if;							-- zakonczenie instukcji warunkowej
    end loop;							-- zakonczenie petli
  end process;							-- zakonczenie procesu

end cialo_tb;			        			-- zakonczenie ciala architektonicznego 'cialo_tb'
