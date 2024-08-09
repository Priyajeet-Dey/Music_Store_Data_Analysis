-- Who is the senior most employee based on job title?

select* from employee
order by levels desc
limit 1

-- Which countries has most invoices?

select count(*) as X, billing_country from invoice
group by billing_country
order by X desc

-- What are the top 3 values of total invoice?

select total from invoice
order by total desc
limit 3

-- Which city has the best customers? We would like to throw a promotional music festival in the city we made the most 
-- money. Write a query that returns one city that has the highest sum of invoice totals. 
-- Return both the city name and sum of all invoice totals.


select sum (total) as Invoice_Total, billing_city from invoice
group by billing_city
order by Invoice_Total desc

-- Who is the best customer? The customer who has spent the most money will be declared the best customer. Write a query
-- that returns the person who has spent the most money.

select customer.customer_id, customer.first_name, customer.last_name, sum(invoice.total) as total
from customer
join invoice on customer.customer_id = invoice.customer_id
group by customer.customer_id
order by total desc
limit 1


-- Write a query to return the email, first name, last name, and Genre of all Rock music listeners. Return your list
-- ordered alphabetically by email staring with A.

select Distinct email, first_name, last_name from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
where track_id in(
	select track_id from track
	join genre on track.genre_id = genre.genre_id
	where genre.name = 'Rock'
)

order by email

-- Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the artist name
-- and total track count of the top 10 rock bands.

select artist.artist_id, artist.name, count(artist.artist_id) as number_of_song
from track
join album on album.album_id = track.album_id
join artist on artist.artist_id = album.artist_id
join genre on genre.genre_id = track.genre_id
where genre.name = 'Rock'
group by artist.artist_id
order by number_of_song desc
limit 10

-- Return all the track names that have a song length longer than the average song length. Return the name and milliseconds
-- for each track. Order by the song length with the longest song as listed first.

select name, milliseconds from track
where milliseconds > (select Avg(milliseconds) as Avg_Song_Length from track)
order by milliseconds desc

-- Find how much amount spent by each customer on artists? Write a query to return customer name, artist name, and
-- total spent.

With Best_Selling_Artist as(
select artist.artist_id as artist_id, artist.name as artist_name, sum (invoice_line.unit_price*invoice_line.quantity)
from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	group by 1
	order by 3 desc
	limit 5
)

select customer.customer_id, customer.first_name, customer.last_name, Best_Selling_Artist.artist_name,
	sum (invoice_line.unit_price*invoice_line.quantity) as Amount_Spent
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	join invoice_line on invoice_line.invoice_id = invoice.invoice_id
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join Best_Selling_Artist on Best_Selling_Artist.artist_id = album.artist_id
	group by 1, 2, 3, 4
	order by 5 desc

-- We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre
-- with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries
-- where the maximum number of purchases is shared return all Genres.

with Popular_genre as (
	select count(invoice_line.quantity) as Purchases, customer.country, genre.name, genre.genre_id,
	row_number() over(partition by customer.country order by count(invoice_line.quantity) desc) as Row_numb
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on invoice.customer_id = customer.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,4
	order by 2 asc,
	
	1 desc
)

	select*from Popular_genre
	where Row_numb<=1

-- Write a query that determines the customer that has spent the most on music for each country. Write a query that returns
-- the country along with top customers and how much they spent. For countries where the top amount spent is shared, 
-- provide all customers who spent this amount.


With customer_from_country as (
	select customer.customer_id, customer.first_name, customer.last_name, billing_country, sum(total) as Total_bill,
	row_number() over(partition by billing_country order by sum(total) desc) as Row_No
	from invoice
	join customer on invoice.customer_id = customer.customer_id
	group by 1,2,3,4
	order by 4 asc, 5 desc
)

select * from customer_from_country
where Row_No<=1
