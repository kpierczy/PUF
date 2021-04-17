library ieee;								-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;					-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;					-- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_TX_SM is
  generic (
    F_ZEGARA		:natural := 50_000_000;				-- czestotliwosc zegata w [Hz]
    L_BODOW		:natural := 9600;				-- predkosc nadawania w [bodach]
    B_SLOWA		:natural := 8;					-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 1;					-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 2;					-- liczba bitow stopu (1-2)
    N_TX		:boolean := FALSE;				-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := FALSE				-- negacja logiczna slowa danych
  );
  port (
    R		        :in  std_logic;					-- sygnal resetowania
    C		        :in  std_logic;					-- zegar taktujacy
    TX		        :out std_logic;					-- wysylany sygnal szeregowy
    SLOWO	        :in  std_logic_vector(B_SLOWA-1 downto 0);	-- wysylane slowo danych
    NADAJ	        :in  std_logic;					-- flaga zadania nadania
    WYSYLANIE	        :out std_logic					-- flaga potwierdzenia wysylanie
  );
end SERIAL_TX_SM;

architecture cialo of SERIAL_TX_SM is

  signal   bufor	:std_logic_vector(SLOWO'range);			-- rejestr kolejno odebranych bitow danych
  signal   f_parzystosc	:std_logic;					-- flaga parzystosci

  type     ETAP		is (CZEKANIE, START, DANA, PARZYSTOSC, STOP); 	-- lista etapow pracy odbiornika
  signal   stan		:ETAP;						-- rejestr maszyny stanow odbiornika

  signal   nadawaj	:std_logic;					-- wysylany sygnal szeregowy

  constant T		:positive := F_ZEGARA/L_BODOW;			-- czas jednego bodu - liczba taktów zegara
  signal   l_czasu  	:natural range 0 to T-1;			-- licznik czasu jednego bodu
  signal   l_bitow  	:natural range 0 to B_SLOWA-1;			-- licznik odebranych bitow danych lub stopu
  

begin

   process (R, C) is							-- proces odbiornika
   begin

     if (R='0') then							-- asynchroniczna inicjalizacja rejestrow
       bufor	    <= (others => '0');					-- wyzerowanie bufora bitow danych
       f_parzystosc <= '0';						-- wyzerowanie flagi parzystosci
       stan	    <= CZEKANIE;					-- poczatkowy stan pracy odbiornika
       l_czasu      <= 0;						-- wyzerowanie licznika czasu bodu
       l_bitow      <= 0;						-- wyzerowanie licznika odebranych bitow
       nadawaj	    <= '0';						-- wyzerowanie sygnalu nadawania szeregowego
       WYSYLANIE    <= '0';						-- wyzerowanie flagi potwierdzenia nadania

     elsif (rising_edge(C)) then					-- synchroniczna praca nadajnika

       nadawaj   <= '0';						-- defaultowe ustawienie sygnalu nadawania szeregowego
       WYSYLANIE <= '1';						-- defaultowe ustawienie flagi potwierdzenia wysylania

       case stan is							-- badanie aktualnego stanu maszyny stanow 

         when CZEKANIE =>						-- obsluga stanu CZEKANIE
           l_czasu <= 0;						-- wyzerowanie licznika czasu bodu
           l_bitow <= 0;						-- wyzerowanie licznika odebranych bitow
	   if (NADAJ='1') then						-- wykrycie zadania nadawania
	     stan         <= START;					-- przejscie do stanu START
             bufor        <= SLOWO;					-- zapisanie bufora bitow danych
	     f_parzystosc <= XOR_REDUCE(SLOWO);				-- wyznaczenie flagi parzystosci
             if (N_SLOWO = TRUE) then					-- badanie warunku zanegowania odebranego slowa
               bufor        <= not(SLOWO);				-- zapisanie bufora zanegowanych bitow danych
	       f_parzystosc <= not(XOR_REDUCE(SLOWO));			-- wyznaczenie flagi parzystosci
	     end if;							-- zakonczenie instukcji warunkowej
	   else								-- wariant braku zadania nadawania
             WYSYLANIE <= '0';						-- kasowanie flagi potwierdzenia wysylania
	   end if;							-- zakonczenie instukcji warunkowej

         when START =>							-- obsluga stanu START
	   nadawaj <= '1';						-- wysylanie bitu STRAT
	   if (l_czasu /= T-1) then					-- badanie odliczania okresu bodu
	     l_czasu <= l_czasu + 1;					-- zwiekszenie o 1 stanu licznika czasu
	   else								-- zakonczenie odliczania okresu bodu
             l_czasu <= 0;						-- wyzerowanie licznika czasu bodu
	     stan    <= DANA;						-- przejscie do stanu DANA
	   end if;							-- zakonczenie instukcji warunkowej

         when DANA =>							-- obsluga stanu DANA
	   nadawaj <= bufor(0);						-- wysylanie najmlodszego bitu danych bufora
	   if (l_czasu /= T-1) then					-- badanie odliczania okresu bodu
	     l_czasu <= l_czasu + 1;					-- zwiekszenie o 1 stanu licznika czasu
	   else								-- zakonczenie odliczania okresu bodu
	     bufor(bufor'left) <= '0';					-- kasowanie najstarszego bitu danych
	     bufor(bufor'left-1 downto 0) <= bufor(bufor'left downto 1);-- przesuniecie bitow w buforze
             l_czasu <= 0;						-- wyzerowanie licznika czasu bodu
	     
	     if (l_bitow /= B_SLOWA-1) then				-- badanie odliczania bitow danych
	       l_bitow <= l_bitow + 1;					-- zwiekszenie o 1 liczby bitow danych
	     else							-- zakonczenie odliczania bitow danych
	       l_bitow <= 0;						-- wyzerowanie licznika odebranych bitow
	       if (B_PARZYSTOSCI = 1) then				-- badanie odbioru bitu parzystosci
	         stan <= PARZYSTOSC;					-- przejscie do stanu PARZYSTOSC
	       else							-- brak odbioru bitu parzystosci  
	         stan <= STOP;						-- przejscie do stanu STOP
	       end if;							-- zakonczenie instukcji warunkowej
	     end if; 							-- zakonczenie instukcji warunkowej 

	   end if;							-- zakonczenie instukcji warunkowej

         when PARZYSTOSC =>						-- obsluga stanu PARZYSTOSC
	   nadawaj <= f_parzystosc;					-- wysylanie bitu parzystosci
	   if (l_czasu /= T-1) then					-- badanie odliczania ookresu bodu
	     l_czasu <= l_czasu + 1;					-- zwiekszenie o 1 stanu licznika czasu
	   else								-- zakonczenie odliczania okresu bodu
             l_czasu <= 0;						-- wyzerowanie licznika czasu bodu
	     stan    <= STOP;						-- przejscie do stanu STOP
	   end if;							-- zakonczenie instukcji warunkowej

         when STOP =>							-- obsluga stanu STOP
	   if (l_czasu /= T-1) then					-- badanie odliczania okresu bodu
	     l_czasu <= l_czasu + 1;					-- zwiekszenie o 1 stanu licznika czasu
	   else								-- zakonczenie odliczania okresu bodu
             l_czasu <= 0;						-- wyzerowanie licznika czasu bodu

	     if (l_bitow /= B_STOPOW-1) then				-- badanie odliczania bitow stopu
	       l_bitow <= l_bitow + 1;					-- zwiekszenie o 1 liczby bitow stopu
	     else							-- zakonczenie odliczania bitow stopu
               WYSYLANIE <= '0';					-- kasowanie flagi potwierdzenia wysylania
	       stan      <= CZEKANIE;					-- przejscie do stanu CZEKANIE
 	     end if;							-- zakonczenie instukcji warunkowej 

	   end if;							-- zakonczenie instukcji warunkowej

       end case;							-- zakonczenie instukcji warunkowego wyboru

     end if;								-- zakonczenie instukcji warunkowej porcesu

   end process;								-- zakonczenie ciala procesu

   TX <= nadawaj when N_TX = FALSE else not(nadawaj);			-- opcjonalne zanegowanie sygnalu TX
   
end cialo;
