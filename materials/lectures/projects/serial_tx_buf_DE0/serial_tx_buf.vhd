library ieee;								-- klauzula dostepu do biblioteki 'IEEE'
use     ieee.std_logic_1164.all;					-- dolaczenie calego pakietu 'STD_LOGIC_1164'
use     ieee.std_logic_misc.all;					-- dolaczenie calego pakietu 'STD_LOGIC_MISC'

entity SERIAL_TX_BUF is
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
end SERIAL_TX_BUF;

architecture cialo of SERIAL_TX_BUF is

  signal   nadawanie	:std_logic;					-- rejestr sygnalu nadawania

  constant T		:positive := F_ZEGARA/L_BODOW;			-- czas jednego bodu - liczba taktów zegara
  signal   l_czasu  	:natural range 0 to T-1;			-- licznik czasu jednego bodu
  
  constant B_RAMKI	:positive := 1+B_SLOWA+B_PARZYSTOSCI+B_STOPOW;	-- liczba odebranych bitow ramki
  signal   l_bitow  	:natural range 0 to B_RAMKI;			-- licznik odebranych bitow ramki
  signal   ramka	:std_logic_vector(B_RAMKI-1 downto 0);		-- rejestr kolejno odebranych bitow danych

begin

   process (R, C) is							-- proces odbiornika
   begin								-- cialo procesu odbiornika

     if (R='0') then							-- asynchroniczna inicjalizacja rejestrow
       nadawanie <= '0';						-- wyzerowanie rejestru nadawania 
       l_czasu   <= 0;							-- wyzerowanie licznika czasu bodu
       l_bitow   <= 0;							-- wyzerowanie licznika odebranych bitow
       ramka	 <= (others => '0');					-- wyzerowanie bitow ramki
     elsif (rising_edge(C)) then					-- synchroniczna praca odbiornika

       if (nadawanie='0') then						-- badanie stanu braku nadawania
         l_czasu   <= 0;						-- wyzerowanie licznika czasu bodu
         l_bitow   <= 0;						-- wyzerowanie licznika odebranych bitow
         nadawanie <= NADAJ;						-- przypisanie sygnalu 'NADAJ' do 'nadawanie'
	 ramka(0)  <= '1';						-- przypisanie do bitu 'ramka(0)' stanu START
	 ramka(B_SLOWA downto 1) <= SLOWO;				-- przypisanie do bitow 'ramka(B_SLOWA downto 1)' wartosci 'SLOWA'
	 ramka(B_SLOWA+1)        <= XOR_REDUCE(SLOWO);			-- przypisanie do bitu 'ramka(B_SLOWA+1)' wartosci parzystosci
         if (N_SLOWO = TRUE) then					-- badanie warunku zanegowania odebranego slowa
	   ramka(B_SLOWA downto 1) <= not(SLOWO);			-- przypisanie do bitow 'ramka(B_SLOWA downto 1)' negacji 'SLOWA'
	   ramka(B_SLOWA+1)        <= not(XOR_REDUCE(SLOWO));		-- przypisanie do bitu 'ramka(B_SLOWA+1)' negacji parzystosci
         end if;							-- zakonczenie instukcji warunkowej  
	 ramka(ramka'left downto B_SLOWA+B_PARZYSTOSCI+1) <= (others => '0'); -- przypisanie do ostatnich bitow 'ramka' liczby bitow STOP
       else								-- wariant dla stanu nadawania
         if (l_czasu=T-1) then						-- badanie zakonczenia czasu oczekiwania jednego bodu
           l_czasu <= 0;						-- wyzerowanie licznika czasu bodu
	   if (l_bitow=B_RAMKI-1) then					-- badanie wyslania wszystkich bitow ramki
             l_bitow   <= 0;						-- wyzerowanie licznika odebranych bitow
             nadawanie <= '0';						-- wyzerowanie flagi nadawania
           else								-- wariant dla niespelnionego warunku
             ramka(ramka'left) <= '0';					-- zapamietanie stanu bitu danych
             ramka(ramka'left-1 downto 0) <= ramka(ramka'left downto 1);-- przesuniecie bitow w ramce
             l_bitow <= l_bitow + 1;					-- zwiekszenie licznika bitow ramki
	   end if;							-- zakonczenie instukcji warunkowej 
	 else								-- wariant dla niespelnionego warunku
           l_czasu <= l_czasu + 1;					-- zwiekszenie licznika czasu
	 end if;							-- zakonczenie instukcji warunkowej 
       end if;								-- zakonczenie instukcji warunkowej 
     end if;								-- zakonczenie instukcji warunkowej procesu
	
   end process;								-- zakonczenie ciala procesu

  TX <= not(ramka(0) and nadawanie) when N_TX=TRUE else			-- wariantowe przypisanie portu wyjsciowego 'TX'
            ramka(0) and nadawanie;
  WYSYLANIE <= NADAWANIE;						-- przypisanie portu wyjsciowego 'WYSYLANIE' 

end cialo;
