library std;
use     std.textio.all;

entity PLIK_ODCZYT_TB is
  generic (
    NAZWA_PLIKU		:string := "..\plik.txt"	-- nazwa pliku tekstowego
  );
end PLIK_ODCZYT_TB;

architecture behavioural of PLIK_ODCZYT_TB is

begin

  process is
    file     ID :TEXT open READ_MODE is NAZWA_PLIKU;	-- otwarcie pliku w trybie odczytu
    variable L : LINE;					-- bufor tresci linii
    variable N : natural;				-- bufor liczby
    variable F : boolean;				-- bufor flagi poprawnosci
  begin
    while (endfile(ID)=FALSE) loop
      readline(ID, L);					-- odczytanie linii z pliku   
      for i in 0 to 6 loop    
        read(L, N, F);					-- odczytanie kolejnych znakow liczby
        report "liczba: " & integer'image(N) & " flaga: " & boolean'image(F);
      end loop;      
    end loop;      
    wait;    
  end process;

end behavioural;
