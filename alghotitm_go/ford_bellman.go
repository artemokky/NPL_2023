package main

import (
	"fmt"
	"strconv"
)

func main() {
	MAX := 30000

	var vertexes, edges int
	fmt.Scan(&vertexes)
	fmt.Scan(&edges)

	from := make([]int, edges)
	to := make([]int, edges)
	weight := make([]int, edges)
	dist := make([]int, vertexes)

	for i := range weight {
		fmt.Scan(&from[i])
		fmt.Scan(&to[i])
		fmt.Scan(&weight[i])

		from[i] = from[i] - 1
		to[i] = to[i] - 1
	}

	for i := range dist {
		dist[i] = MAX
	}
	dist[0] = 0

	for i := range dist {
		i = i
		for j := range weight {
			if dist[from[j]] < MAX {
				distance := dist[from[j]] + weight[j]
				if distance < dist[to[j]] {
					dist[to[j]] = distance
				}
			}
		}
	}

	for i := range dist {
		fmt.Printf(strconv.Itoa(dist[i]))
		fmt.Printf(" ")
	}
}
