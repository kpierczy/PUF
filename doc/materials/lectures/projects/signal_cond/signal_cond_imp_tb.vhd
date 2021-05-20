library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity SIGNAL_COND_IMPL_TB is			-- pusty sprzeg projektu symulacji
end SIGNAL_COND_IMPL_TB;

architecture behavioural of SIGNAL_COND_IMPL_TB is 	-- cialo architektoniczne projektu

  signal A	:natural range 0 to 15 := 0;	-- symulowane wejscie 'A' inicjowane na 0
  signal B	:natural range 0 to 15 := 0;	-- symulowane wejscie 'B' inicjowane na 0
  signal Y	:natural range 0 to 15;		-- obserwowane wyjscie 'Y'
  signal W	:natural range 0 to 3;		-- obserwowane wyjscie 'W'
  signal S	:natural range 0 to 3;		-- testowy sygnal wyboru 'S'
  signal T	:boolean;			-- testowy sygnal zgodnosci 'T'

  signal Av	:std_logic_vector(3 downto 0);	-- symulowane wejscie wektora bitowego 'Av'
  signal Bv	:std_logic_vector(3 downto 0);	-- symulowane wejscie wektora bitowego 'Bv'
  signal Yv	:std_logic_vector(3 downto 0);	-- symulowane wejscie wektora bitowego 'Yv'
  signal Wv	:std_logic_vector(1 downto 0);	-- symulowane wejscie wektora bitowego 'Wv'
  
  constant step :time := 100 ns;

begin						-- poczatek czesci wykonawczej architektury

  process is					-- proces bezwarunkowy
  begin						-- czesc wykonawcza procesu
    wait for step; A <= A+1;
    --wait for 10 ns; A <= (A+1) mod 16;		-- odczekanie step [ns] i zwiekszenie o 1 sygnalu A
  end process;					-- zakonczenie procesu
  
  process is begin
    wait for 16*step; B <= (B+1) mod 16;	-- odczekanie 16*step [ns] i zwiekszenie o 1 sygnalu B
  end process;

  Av <= "0000"+A;
  Bv <= "0000"+B;
  
  signal_cond_impl: entity work.LCELL(Structure) -- instancja projektu 'SIGNAL_COND'
    port map (				-- mapowanie portow
      argA     => Av,			-- przypisanie sygnalu 'Av' do portu 'argA'
      argB     => Bv,			-- przypisanie sygnalu 'Bv' do portu 'argB'
      rezultat => Yv,			-- przypisanie sygnalu 'Yv' do portu 'rezultat'
      wybor    => Wv			-- przypisanie sygnalu 'Wv' do portu 'wybor'
    );

  S <= 0 when A - 5 > B else		-- wybor gdy 'A - 5 > B'
       1 when A     > B else		-- wybor gdy 'A > B'
       2 when B - 7 > A else		-- wybor gdy 'B - 7 > A'
       3;				-- wybor w pozostalych przypadkach

  T <= (S = Wv);

end behavioural;			-- zakonczenie ciala architektonicznego
