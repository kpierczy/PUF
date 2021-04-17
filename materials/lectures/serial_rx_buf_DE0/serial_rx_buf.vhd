library ieee;								-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;					-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;					-- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_RX_BUF is
  generic (
    F_ZEGARA		:natural := 50_000_000;				-- czestotliwosc zegata w [Hz]
    L_BODOW		:natural := 9600;				-- predkosc nadawania w [bodach]
    B_SLOWA		:natural := 8;					-- liczba bitow slowa danych (5-8)
    B_PARZYSTOSCI	:natural := 1;					-- liczba bitow parzystosci (0-1)
    B_STOPOW		:natural := 2;					-- liczba bitow stopu (1-2)
    N_RX		:boolean := FALSE;				-- negacja logiczna sygnalu szeregowego
    N_SLOWO		:boolean := FALSE				-- negacja logiczna slowa danych
  );
  port (
    R		:in  std_logic;						-- sygnal resetowania
    C		:in  std_logic;						-- zegar taktujacy
    RX		:in  std_logic;						-- odebrany sygnal szeregowy
    SLOWO	:out std_logic_vector(B_SLOWA-1 downto 0);		-- odebrane slowo danych
    GOTOWE	:out std_logic;						-- flaga potwierdzenia odbioru
    BLAD	:out std_logic						-- flaga wykrycia bledu w odbiorze
  );
end SERIAL_RX_BUF;

architecture cialo of SERIAL_RX_BUF is

  signal   wejscie	:std_logic_vector(0 to 1);			-- podwojny rejestr sygnalu RX

  constant T		:positive := F_ZEGARA/L_BODOW;			-- czas jednego bodu - liczba taktów zegara
  signal   l_czasu  	:natural range 0 to T-1;			-- licznik czasu jednego bodu
  
  constant B_RAMKI	:positive := B_SLOWA+B_PARZYSTOSCI+B_STOPOW;	-- liczba odebranych bitow ramki
  signal   l_bitow  	:natural range 0 to B_RAMKI;			-- licznik odebranych bitow ramki
  signal   ramka	:std_logic_vector(B_RAMKI-1 downto 0);		-- rejestr kolejno odebranych bitow danych

begin

   process (R, C) is							-- proces odbiornika
   begin								-- cialo procesu odbiornika

     if (R='0') then							-- asynchroniczna inicjalizacja rejestrow
       wejscie	<= (others => '0');					-- wyzerowanie rejestru sygnalu RX
       l_czasu  <= 0;							-- wyzerowanie licznika czasu bodu
       l_bitow  <= 0;							-- wyzerowanie licznika odebranych bitow
       ramka	<= (others => '0');					-- wyzerowanie bitow ramki
       SLOWO	<= (others => '0');					-- wyzerowanie wyjsciowego slowa danych
       GOTOWE	<= '0';							-- wyzerowanie flagi potwierdzenia odbioru
       BLAD	<= '0';							-- wyzerowanie flagi wykrycia bledu w odbiorze

     elsif (rising_edge(C)) then					-- synchroniczna praca odbiornika

       GOTOWE     <= '0';						-- defaultowe skasowanie flagi potwierdzenia odbioru
       BLAD       <= '0';						-- defaultowe skasowanie flagi wykrycia bledu w odbiorze
       wejscie(0) <= RX;						-- zarejestrowanie synchroniczne stanu sygnalu RX
       if (N_RX = TRUE) then						-- badanie warunku zanegowania sygnalu szeregowego
         wejscie(0) <= not(RX);						-- zarejestrowanie synchroniczne zanegowanego sygnalu RX
       end if;								-- zakonczenie instukcji warunkowej  
       wejscie(1) <= wejscie(0);					-- zarejestrowanie dwoch kolejnych stanow sygnalu RX

       if (l_bitow=0 and l_czasu=0) then				-- badanie stanu oczekiwania na poczatek transmisji
         if (wejscie(0)='1' and wejscie(1)='0') then			-- badanie rozpoczecia transmisji bitu startu
           l_czasu <= l_czasu + 1;					-- zwiekszenie licznika czasu
	 end if;							-- zakonczenie instukcji warunkowej 
       else								-- wariant dla trwania odbioru ramki
         if ((l_bitow=0 and l_czasu=T/2-1) or l_czasu=T-1) then		-- badanie zakonczenia czasu oczekiwania
           l_czasu <= 0;						-- wyzerowanie licznika czasu bodu
	   if (l_bitow=B_RAMKI) then					-- badanie odebrania calej ramki
             SLOWO  <= (others => '0');					-- wyzerowanie wyjsciowego slowa danych
             BLAD   <= '1';						-- ustawienie flagi bledu odbioru
	     if (ramka(0)='1' and ((B_STOPOW=1 or ramka(ramka'left)='0') and wejscie(1)='0')) then -- badanie poprawnosci odbioru
               if (N_SLOWO = TRUE) then					-- badanie warunku zanegowania odebranego slowa
	         if (B_PARZYSTOSCI=0 or (ramka(B_SLOWA+1)/=XOR_REDUCE(ramka(B_SLOWA downto 1)))) then -- badanie poprawnosci odbioru
                   SLOWO  <= not(ramka(B_SLOWA downto 1));		-- podstawienie wyjsciowego slowa danych
                   BLAD   <= '0';					-- skasowanie flagi bledu odbioru
                   GOTOWE <= '1';					-- ustawienie flagi potwierdzenia odbioru
                 end if;						-- zakonczenie instukcji warunkowej  
	       else							-- wariant dla niespelnionego warunku
	         if (B_PARZYSTOSCI=0 or (ramka(B_SLOWA+1)=XOR_REDUCE(ramka(B_SLOWA downto 1)))) then -- badanie poprawnosci odbioru
                   SLOWO  <= ramka(B_SLOWA downto 1);			-- podstawienie wyjsciowego slowa danych
                   BLAD   <= '0';					-- skasowanie flagi bledu odbioru
                   GOTOWE <= '1';					-- ustawienie flagi potwierdzenia odbioru
                 end if;						-- zakonczenie instukcji warunkowej  
               end if;							-- zakonczenie instukcji warunkowej  
             end if;							-- zakonczenie instukcji warunkowej  
	     l_bitow <= 0;						-- wyzerowanie licznika bitow ramki
           else								-- wariant dla niespelnionego warunku
             ramka(ramka'left) <= wejscie(1);				-- zapamietanie stanu bitu danych
             ramka(ramka'left-1 downto 0) <= ramka(ramka'left downto 1);-- przesuniecie bitow w ramce
             l_bitow <= l_bitow + 1;					-- zwiekszenie licznika bitow ramki
	   end if;							-- zakonczenie instukcji warunkowej porcesu
	 else								-- wariant dla niespelnionego warunku
           l_czasu <= l_czasu + 1;					-- zwiekszenie licznika czasu
	 end if;							-- zakonczenie instukcji warunkowej porcesu
       end if;								-- zakonczenie instukcji warunkowej porcesu
     end if;								-- zakonczenie instukcji warunkowej porcesu
	
   end process;								-- zakonczenie ciala procesu
   
end cialo;
