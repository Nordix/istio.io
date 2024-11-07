---
title: Однаковість просторів імен
test: n/a
---

У межах multicluster mesh застосовується [однаковість просторів імен](https://github.com/kubernetes/community/blob/master/sig-multicluster/namespace-sameness-position-statement.md), і всі простори імен із вказаним імʼям вважаються одним і тим самим простором імен. Якщо в кількох кластерах міститься `Service` з тим самим іменем у просторі імен, вони будуть розглядатися як один обʼєднаний сервіс. Стандартно трафік розподіляється між усіма кластерами в mesh для даного сервісу.

Порти, які збігаються за _номером_, також повинні мати однакове _імʼя порту_, щоб вважатися обʼєднаним `service port`.