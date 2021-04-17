package PACKAGE_SUM is						-- deklaracja pakietu 'PACKAGE_SUM'

  function sumator(A, B :bit_vector) return bit_vector; 	-- deklaracja funkcji 'sumator'
  function "+"(A, B :bit_vector) return bit_vector;		-- deklaracja funkcji operatorowej '+'

end package PACKAGE_SUM;	 				-- zakonczenie deklaracji pakietu 'PACKAGE_SUM'

package body PACKAGE_SUM is					-- deklaracja ciala pakietu 'PACKAGE2B'

  function max(A,B :positive) return positive is		-- utworzenie niepublicznej procedury 'max'
  begin								-- czesc wykonawcza procedury
    if (A>=B) then return A; end if;				-- zbadanie i zwrocenie wartosci 'A' gdy nie mniejsze niz 'B'
    return B;							-- zwrocenie wartosci 'B'
  end function max;						-- zakonczenie procedury

  function sumator(A, B :bit_vector) return bit_vector is 	-- utworzenie publicznej funkcji 'sumator'
    
    constant N : positive := max(A'length,B'length);		-- utworzenie stalej 'N' o watosci maksymalnej dlugosci wektora
    variable AN, BN, Y : bit_vector(N-1 downto 0) := (others => '0'); -- utworzenie zmiennych 'AN', 'BN', 'Y'
    
    function sum(A, B :bit_vector) return bit_vector is 	-- utworzenie funkcji  'sum'
      variable P, S : bit;					-- utworzenie zmiennych 'P' i 'S' w procedurze
      variable Y : bit_vector(A'range);				-- utworzenie zmiennej 'Y' w procedurze
      procedure sum(A, B :bit; S :out bit ; P :inout bit) is	-- utworzenie wewnetrznej procedury 'sum'
      begin							-- czesc wykonawcza procedury
        if (P='0') then						-- badanie czy bit przeniesienia jest rowny '0'
          S := A xor B;						-- sumowanie bitowe funkcja 'xor'
          P := A and B;						-- wyznaczenie bitu przeniesienia funkcja 'and'
        else							-- wariant dla 'P' rownego '1'
          S := A xnor B;					-- sumowanie bitowe funkcja 'xnor'
          P := A or   B;					-- wyznaczenie bitu przeniesienia funkcja 'or'
        end if;							-- zakonczenie instukcji warunkowej
      end procedure sum;					-- zakonczenie procedury
    begin							-- czesc wykonawcza procedury
      P := '0';							-- ustawienie wartosci poczatkowej 'P' na '0'
      for i in 0 to Y'length-1 loop				-- petla po kolejnych bitach dla identyfikatora 'i'
        sum(A(i),B(i),S,P);					-- wywolanie procedury wewnetrznej 'sum'
        Y(i) := S;						-- przypisanie zmiennej 'S' do portu 'Y(i)'
      end loop;							-- zakonczenie petli
      return Y;							-- zwrocenie zmiennej 'Y'
    end function sum;						-- zakonczenie funcji
 
  begin								-- czesc wykonawcza procedury
    AN(A'range) := A;						-- czesciowe przypisanie zmiennej'AN'
    BN(B'range) := B;						-- czesciowe przypisanie zmiennej'BN'
    return sum(AN, BN);						-- zwrocenie rezultatu funcji 'sum'
  end function sumator;						-- zakonczenie funcji


  function "+"(A, B :bit_vector) return bit_vector is 		-- utworzenie publicznej funkcji operatorowej '+'
  begin								-- czesc wykonawcza procedury
    return sumator(A,B);					-- zwrocenie rezultatu funkcji 'sumator'
  end function "+";						-- zakonczenie funcji operatorowej '+'

end package body PACKAGE_SUM;	 				-- zakonczenie deklaracji ciala pakietu 'PACKAGE_SUM'
