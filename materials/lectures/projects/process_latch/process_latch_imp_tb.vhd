library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity PROCESS_LATCH_IMP_TB is		-- pusty sprzeg projektu symulacji
end PROCESS_LATCH_IMP_TB;

architecture behavioural of PROCESS_LATCH_IMP_TB is -- cialo architektoniczne projektu

  signal  ascii		:character; 
  signal  ascii_vec	:std_logic_vector(7 downto 0); 
  signal  low_char  	:std_logic; 
  signal  high_char 	:std_logic; 
  signal  digit     	:std_logic; 
  signal  control	:std_logic; 

  signal low_char_err	:bit;		-- obserwowane wyjscie bledu 'low_char'
  signal high_char_err	:bit;		-- obserwowane wyjscie bledu 'high_char'
  signal digit_err	:bit;		-- obserwowane wyjscie bledu 'digit'
  signal control_err	:bit;		-- obserwowane wyjscie bledu 'control'
	
begin						-- czesc wykonawcza ciala projektu

  process is					-- proces bezwarunkowy
  begin						-- czesc wykonawcza procesu
    ascii <= 'W'; wait for 100 ns;		-- ustawienie sygnalu 'ascii'='W' i odczekanie 10 ns
    ascii <= 'y'; wait for 100 ns;		-- ustawienie sygnalu 'ascii'='y' i odczekanie 10 ns
    ascii <= 'k'; wait for 100 ns;		-- ustawienie sygnalu 'ascii'='k' i odczekanie 10 ns
    ascii <= 'l'; wait for 100 ns;		-- ustawienie sygnalu 'ascii'='l' i odczekanie 10 ns
    ascii <= 'a'; wait for 100 ns;		-- ustawienie sygnalu 'ascii'='a' i odczekanie 10 ns
    ascii <= 'd'; wait for 100 ns;		-- ustawienie sygnalu 'ascii'='d' i odczekanie 10 ns
    ascii <= ' '; wait for 100 ns;		-- ustawienie sygnalu 'ascii'=' ' i odczekanie 10 ns
    ascii <= '5'; wait for 100 ns;		-- ustawienie sygnalu 'ascii'='5' i odczekanie 10 ns
    ascii <= LF;  wait for 100 ns;		-- ustawienie sygnalu 'ascii'='LF' i odczekanie 10 ns
    ascii <= CR;  wait for 100 ns;		-- ustawienie sygnalu 'ascii'='CR' i odczekanie 10 ns
  end process;

  process (ascii) is
    variable pos :integer;
  begin
    pos := character'pos(ascii);
    ascii_vec <= (ascii_vec'range => '0') + pos;
  end process;

  process_latch_inst: entity work.PROCESS_LATCH(Structure) -- instancja projektu 'PROCESS_LATCH'
    port map (					-- mapowanie portow
      ascii     => ascii_vec,			-- przypisanie sygnalu 'ascii' do portu 'ascii'
      low_char  => low_char,			-- przypisanie sygnalu 'low_char' do portu 'low_char'
      high_char => high_char,			-- przypisanie sygnalu 'high_char' do portu 'high_char'
      digit     => digit,			-- przypisanie sygnalu 'digit' do portu 'digit'
      control   => control			-- przypisanie sygnalu 'control' do portu 'control'
    );

    low_char_err  <= '1' when (ascii>='a' and ascii<='z') /= (low_char='1')  else '0'; -- test malej liter
    high_char_err <= '1' when (ascii>='A' and ascii<='Z') /= (high_char='1') else '0'; -- test duzej liter
    digit_err     <= '1' when (ascii>='0' and ascii<='9') /= (digit='1')     else '0'; -- test cyfry
    control_err   <= '1' when (ascii>=NUL and ascii<=USP) /= (control='1')   else '0'; -- test znaku kontrolnego

end behavioural;				-- zakonczenie ciala architektonicznego
