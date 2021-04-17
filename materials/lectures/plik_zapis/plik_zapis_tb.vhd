library std;
use     std.textio.all;

entity PLIK_ZAPIS_TB is
  generic (
    NAZWA_PLKU		:string := "..\plik.txt";	-- nazwa pliku tekstowego
    TRYB_ZAPISU		:FILE_OPEN_KIND := APPEND_MODE	-- tryb zapisu: WRITE_MODE lub APPEND_MODE
  );
end PLIK_ZAPIS_TB;

architecture behavioural of PLIK_ZAPIS_TB is

begin

  process is
    file     ID :TEXT open TRYB_ZAPISU is NAZWA_PLKU;	-- otwarcie pliku z czyszczeniem
    variable L : LINE;					-- bufor tresci linii
  begin
    write(L, "nowy tekst ");					-- dopisanie ciagu znakow na koncu linii
    for i in 0 to 5 loop    
      write(L, 3*i+30);					-- dopisanie znakow liczby na koncu linii 
      write(L, ", ");					-- dopisanie ciagu znakow na koncu linii
    end loop;      
    write(L, 113);					-- dopisanie znakow liczby na koncu linii   
    writeline(ID, L);					-- zapisanie linii do pliku   
    write(L, 213);					-- dopisanie znakow liczby na koncu linii   
    writeline(ID, L);					-- zapisanie linii do pliku   
    write(L, 313);					-- dopisanie znakow liczby na koncu linii   
    writeline(ID, L);					-- zapisanie linii do pliku   
    wait;    
  end process;

end behavioural;
