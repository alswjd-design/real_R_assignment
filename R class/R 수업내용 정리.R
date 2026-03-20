- to make hidden file: put . in front of a file


# logical -> integer -> double -> complex -> character

1L,2L,3L is integer and they are numbers

install.packages("tidyverse")

a <- c("a", 1) # character
b <- c(TRUE, 1) # double because 1 (True is logical)
c <- c(1L, 10) # double because 10 (1L is logical)
d <- c(a, b, c) #character
typeof(a); typeof(b); typeof(c); typeof(d)

mean() changes all the True to 1 and all the False to 0

mean(b)

#list: it is like a hanging. so c(1,2,3) will have 1,2,3 character but list will have column 1, column 2, and column 3 but that column only have one character for NOW. but I can add later
x <- c(1,2,3)
y <- list(1,2,3)
z <- list(1:3, "a", c(TRUE, FALSE, TRUE), c(2.3, 5.9))

is.vector(list(1,2,3))
is.numeric(c(1L,2L,3L))
typeof(as.numeric(c(1L,2L,3L)))

c(1, FALSE)
c("a", 1)
c(list(1), "a")
c(TRUE, 1L)

1 == "1" true? Why is -1 < FALSE true? Why is "one" < 2 is false? why "one">2 is true?
  
  skip matrices

df <- data.frame(x = 1:3, y = c("a", "b", "c"))
str(df)


as.data.frame(): will make one column including data.



## 260227 R class
R은 1부터 세고, Python은 0부터 센데
x[-2:4] 요거는 에러야. 왜냐면 -2를 인지할수 없어
-를 붙이면 그거 빼고 다 보여줘 이런 느낌
x[-2:-4] 요거 의미는 2번째거랑 4번째거 빼고 다 보여줘 (몇번째인지 세는 거는 0부터 말구 1부터 세. R이니까)
names(x) 요거 의미는 x 에 이름을 부여하는 거
names(x) <- c('a', 'b', 'c'...)
x[c(T,T,F)] 요거는  첫번째자리랑 두번째자리 숫자는 T니까 보여주고 pull out but F does not pull out. this pattern goes to all remained numbers
x<25 요거는 넘버를 주는게아니라 T or F로 ouput이 나오네
x[x<25] 요거는 넘버를 주네
x[names(x) %in% c("a", "c", "d")	All elements with names “a”, “c”, or “d”
  x[!(names(x) %in% c("a","c","d"))]	All elements with names other than “a”, “c”, “d”
  #Discussion 1
  x <- c(5.4, 6.2, 7.1, 4.8, 7.5, 6.2)
  names(x) <- c('a', 'b', 'c', 'd', 'e', 'f')
  x[-(2:4)]
  x[-2:4] error
  -x[2:4] 
  x[names(x) == "a"]
  
  single brackets []은 list의 첫 column이라 해야하나 그 집합을 가져오는거고 double brackets [[]]은 그 column의 individuals 가져오는거야 
  
  #Discussion 2
  lst <- list(1:3, "a", c(TRUE, FALSE, TRUE), c(2.3, 5.9)) shows error because lst[1:2]랑 lst[1][2]의 차이야
  #Discussion 3
  df[2:3,4,5] 는 row랑 column이 1부터 5까지 있다고 하면, row 2,3,이랑 column 4,5의 교집합 부분을 보여줘
  
  ##Questions
  How many windows have >= 85 SNPs? 3
    What is a SNP? single nucleotide peptide
    
    
    26.03.06
    #As another example, consider looking at Pi by windows that fall in the centromere and those that do not. Does the centromer have higher nucleotide diversity than other regions in these data?
    
    >dvst_cent <- group_by(dvst, cent)
    >summarise(dvst_cent, mean_d =  mean(Pi)
    
    #pipe
    >dvst %>% group_by(cent) %>% summarise(mean_d = mean(Pi))
    
    #Visualize
    take a photo
    
    