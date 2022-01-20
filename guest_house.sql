-- 1. Give the booking_date and the number of nights for guest 1183

SELECT booking_date, nights 
FROM booking 
WHERE guest_id = 1183


-- 2. List the arrival time and the first and last names for all guests due to arrive on 2016-11-05, order the output by time of arrival

SELECT b.arrival_time, g.first_name, g.last_name 
FROM booking b
    INNER JOIN guest g
         ON b.guest_id = g.id 
WHERE b.booking_date = '2016-11-05'
ORDER BY b.arrival_time


-- 3.  Give the daily rate that should be paid for bookings with ids 5152, 5165, 5154 and 5295. Include booking id, room type, number of occupants and the amount 

SELECT b.booking_id, b.room_type_requested, b.occupants, r.amount
FROM booking b
    INNER JOIN rate r 
        ON b.room_type_requested = r.room_type
        AND b.occupants = r.occupancy
WHERE b.booking_id IN (5152,5165,5154,5295)



-- 4. Find who is staying in room 101 on 2016-12-03, include first name, last name and address

SELECT g.first_name,g.last_name,g.address
FROM booking b 
    INNER JOIN guest g 
        ON b.guest_id = g.id 
WHERE b.booking_date = '2016-12-03'
AND b.room_no = 101



-- 5. For guests 1185 and 1270 show the number of bookings made and the total number of nights. Your output should include the guest id and the total number of bookings and the total number of nights.

SELECT g.id, COUNT(b.nights) as total_bookings,SUM(b.nights) as total_nights
FROM booking b 
    INNER JOIN guest g 
        ON b.guest_id = g.id 
WHERE b.guest_id IN (1185,1270)
GROUP BY g.id


-- 6. Show the total amount payable by guest Ruth Cadbury for her room bookings. You should JOIN to the rate table using room_type_requested and occupants

SELECT SUM(b.nights * r.amount) as amount_payable
FROM booking b 
INNER JOIN rate r
   ON b.room_type_requested = r.room_type
   AND b.occupants = r.occupancy
INNER JOIN guest g 
   ON g.id = b.guest_id
 WHERE g.first_name = 'Ruth'
 And g.last_name = 'Cadbury'


 -- 7. Calculate the total bill for booking 5346 including extras

 WITH e AS (
    SELECT booking_id, sum(amount) AS extras
    FROM extra
    GROUP BY booking_id
)
SELECT SUM(b.nights * r.amount) + SUM(e.extras) AS total
FROM booking b INNER JOIN rate r 
        ON b.occupants = r.occupancy
        AND b.room_type_requested = r.room_type 
    INNER JOIN e 
        ON b.booking_id = e.booking_id
WHERE b.booking_id = 5346


-- 8. For every guest who has the word “Edinburgh” in their address show the total number of nights booked. Be sure to include 0 for those guests who have never had a booking. Show last name, first name, address and number of nights. Order by last name then first name


SELECT g.last_name,g.first_name, g.address,
  CASE 
      WHEN SUM(b.nights) IS NULL 
      THEN 0 
      ELSE SUM(b.nights) 
  END AS nights
FROM booking b 
    RIGHT JOIN guest g 
        ON b.guest_id = g.id
WHERE address LIKE '%Edinburgh%'
GROUP BY g.last_name,g.first_name,g.address
ORDER BY g.last_name,g.first_name


-- 9. For each day of the week beginning 2016-11-25 show the number of bookings starting that day. Be sure to show all the days of the week in the correct order

SELECT booking_date, COUNT(booking_id) AS arrivals 
FROM booking
WHERE 
  booking_date BETWEEN'2016-11-25' AND '2016-12-01'
GROUP BY booking_date
ORDER BY booking_date 


-- 10. Show the number of guests in the hotel on the night of 2016-11-21. Include all occupants who checked in that day but not those who checked out

SELECT SUM(occupants) 
FROM booking 
WHERE booking_date <= '2016-11-21'
    AND DATE_ADD(booking_date,INTERVAL nights DAY) > '2016-11-21' 


-- 11. Have two guests with the same surname ever stayed in the hotel on the evening? Show the last name and both first names. Do not include duplicates

WITH g1 AS 
    (
        SELECT b.booking_date,b.nights,g.first_name,g.last_name 
        FROM booking b 
            INNER JOIN guest g 
                ON b.guest_id = g.id
),

g2 AS 
    (
      SELECT b.booking_date,b.nights,g.first_name,g.last_name 
      FROM booking b 
            INNER JOIN guest g 
                ON b.guest_id = g.id    
)

SELECT DISTINCT g1.last_name, g1.first_name,g2.first_name 
FROM g1 
    INNER JOIN g2 
        ON g1.last_name = g2.last_name
        AND g1.first_name <> g2.first_name
WHERE g1.booking_date <= g2.booking_date 
    AND date_add(g1.booking_date, INTERVAL (g1.nights -1) DAY) >= g2.booking_date   
ORDER by g1.last_name
