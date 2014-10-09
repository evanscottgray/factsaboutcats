require 'googlevoiceapi'
require 'nokogiri'
require 'json'
$f = 0
@v = GoogleVoice::Api.new('your@email.here', 'datpass')
@facts = ["Both humans and cats have identical regions in the brain responsible for emotion.", "A cat's brain is more similar to a man's brain than that of a dog.", "Miacis, the primitive ancestor of cats, was a small, tree-living creature of the late Eocene period, some 45 to 50 million years ago.", "Phoenician cargo ships are thought to have brought the first domesticated cats to Europe in about 900 BC.", "Cats respond most readily to names that end in an 'ee' sound.", "The female cat reaches sexual maturity within 6 to 10 months; most veterinarians suggest spaying the female at 5 months, before her first heat period. The male cat usually reaches sexual maturity between 9 and 12 months.", "It has been scientifically proven that stroking a cat can lower one's blood pressure", "In 1987, cats overtook dogs as the number one pet in America (about 50 million cats resided in 24 million homes in 1986). About 37% of American homes today have at least one cat.", "Six-toed kittens are so common in Boston and surrounding areas of Massachusetts that experts consider it an established mutation.", "The silks created by weavers in Baghdad were inspired by the beautiful and varied colors and markings of cat coats. These fabrics were called 'tabby' by European traders.", "Cats have five toes on each front paw, but only four toes on each back paw.", "Cats are sometimes born with extra toes. This is called polydactly. These toes will not harm the cat, but you should keep his claws trimmed just like any toe.", "Cats have true fur, in that they have both an undercoat and an outer coat.", "Newborn kittens have closed ear canals that don't begin to open for nine days.When the eyes open, they are always blue at first. They change color over a period of months to the final eye color.", "Most cats have no eyelashes.", "Cats have a full inner-eyelid, or nictitating membrane. This inner-eyelid serves to help protect the eyes from dryness and damage. When the cat is ill, the inner-eyelid will frequently close partially, making it visible to the observer.", "A cat cannot see directly under its nose. This is why the cat cannot seem to find tidbits on the floor.", "You can tell a cat's mood by looking into its eyes. A frightened or excited cat will have large, round pupils. An angry cat will have narrow pupils. The pupil size is related as much to the cat's emotions as to the degree of light.", "It is a common belief that cats are color blind. However, recent studies have shown that cats can see blue, green and red.", "A large majority of white cats with blue eyes are deaf. White cats with only one blue eye are deaf only in the ear closest to the blue eye. White cats with orange eyes do not have this disability.", "Cats with white fur and skin on their ears are very prone to sunburn. Frequent sunburns can lead to skin cancer. Many white cats need surgery to remove all or part of a cancerous ear. Preventive measures include sunscreen, or better, keeping the cat indoors.", "A cat can jump even seven times as high as it is tall.","The cat's footpads absorb the shocks of the landing when the cat jumps.", "Cats lack a true collarbone. Because of this lack, cats can generally squeeze their bodies through any space they can get their heads through. You may have seen a cat testing the size of an opening by careful measurement with the head.", "If left to her own devices, a female cat may have three to seven kittens every four months. This is why population control using neutering and spaying is so important.", "A cat is pregnant for about 58-65 days.", "Mother cats teach their kittens to use the litter box.", "The way you treat kittens in the early stages of it's life will render it's personality traits later in life.", "Contrary to popular belief, the cat is a social animal. A pet cat will respond and answer to speech , and seems to enjoy human companionship.", "When well treated, a cat can live twenty or more years but the average life span of a domestic cat is 14 years.", "Neutering a cat extends its life span by two or three years.", "Cats, especially older cats, do get cancer. Many times this disease can be treated successfully.", "Cats can't taste sweets.", "Cats must have fat in their diet because they can't produce it on their own.", "Some common houseplants poisonous to cats include: English Ivy, iris, mistletoe, philodendron, and yew.", "Tylenol and chocolate are both poisionous to cats.", "Many cats cannot properly digest cow's milk. Milk and milk products give them diarrhea.", "The average cat food meal is the equivalent to about five mice.", "Cats can get tapeworms from eating fleas. These worms live inside the cat forever, or until they are removed with medication. They reproduce by shedding a link from the end of their long bodies. This link crawls out the cat's anus, and sheds hundreds of eggs. These eggs are injested by flea larvae, and the cycles continues. Humans may get these tapeworms too, but only if they eat infected fleas. Cats with tapeworms should be dewormed by a veterinarian.", "Cats can get tapeworms from eating mice. If your cat catches a mouse it is best to take the prize away from it." ]
def test_bomb(number, phonenumber)

    i = 0

    while i < number
        i += 1
        puts "Sending Message #{i}"
        @v.sms("#{phonenumber}", "This is test message ##{i}.")
        puts "Message #{i} sent."
        st = 0
    
        while st < 5
            p "Asleep for #{st}"
            sleep 0.01
            st +=1
        end
    end
end

def recent
  @inbox_xml = @v.inbox_xml()
  i = 0
  doc = Nokogiri::XML::Document.parse(@inbox_xml)
  data = doc.xpath('/response/json').first.text
  html = Nokogiri::HTML::DocumentFragment.parse(doc.to_html)
  json = JSON.parse(data)       
  # Format for messages is [id, {attributes}]
  json['messages'].map do |conversation|
    next unless conversation[1]['labels'].include? "sms"
    html.css("##{conversation[0]} div.gc-message-sms-row").map do |row|
      next if row.css('span.gc-message-sms-from').inner_html.strip! =~ /Me:/
      text = row.css('span.gc-message-sms-text').inner_html
      time = row.css('span.gc-message-sms-time').inner_html
      from = conversation[1]['phoneNumber']
      
      {
        :id => Digest::SHA1.hexdigest(conversation[0]+text+from),
        :text => text,
        :time => time,
        :from => from,
      }
    end
  end.flatten.compact
end

def check_messages(number)
    @texts = recent().find_all {|x| x[:from] == "+1#{number}"}
    @fact_response = Hash[@texts.map { |r| [r[:text], r] }]
    @commands = []

    @fact_response.each do |find|
         @commands <<  find.find_all {|i| i.include? "CAT FACTS:"} 
    end

@commands.flatten!

end

def check_favorite(number)
    @texts = recent().find_all {|x| x[:from] == "+1#{number}"}
    fact_response = Hash[@texts.map { |r| [r[:text], r] }]
    @favorite = []

    fact_response.each do |find|
         @favorite <<  find.find_all {|i| i.include? "ANIMAL:"} 
    end

@favorite.flatten!
p @favorite

# Make sure that favorite isn't empty so that the selection of the last item doesn't flip shit.
if @favorite.empty?
@favorite << "NoResponse"
end
@favorite_string = @favorite.last.to_s.split.last.upcase

end

def send_fact(number, delay, break_count)

    @set_time = Time.now
    @texts = recent().find_all {|x| x[:from] == "+1#{number}"}
    @start_count = @texts.length
    p "Target time: #{@set_time + (delay * 60 * 60)}, Time now: #{Time.now}"
        i = 0 
    breaktime = false
        while breaktime == false
            @texts = recent().find_all {|x| x[:from] == "+1#{number}"}
                if @texts.count >= @start_count + break_count
                    breaktime = true
                    p "Broken, Moving on..."
                end
                #send hourly...
        if Time.now >= @set_time + (delay * 60 * 60)
            to_send = rand(0..@facts.length)
            string_to_send = @facts[to_send]
            @facts.delete(string_to_send)
            @v.sms("#{number}", "#{string_to_send}")
            p "Sent: #{string_to_send}"
            @set_time = Time.now
            @start_count += 1
                        i += 1
            p "New target time set to #{@set_time + (delay * 60 * 60)}, #{@facts.length} remaining cat facts. #{i} facts sent so far. Time now: #{Time.now}"
            sleep 5
    end
    end
end

def wait_for_response(count, number)
    thetime = Time.now
    @texts = recent().find_all {|x| x[:from] == "+1#{number}"}
    @start_count = @texts.length
        p "Time to break: #{thetime + (1 * 60 * 60)} Time now: #{Time.now}"
    breaktime = false
        while breaktime == false
            @texts = recent().find_all {|x| x[:from] == "+1#{number}"}
                if (@texts.count >= @start_count + count)
                    breaktime = true
                    p "Got response, moving on"
                elsif Time.now >= thetime + (1 * 60 * 60)
                    p "hit break time"
                    breaktime = true
                end
            end
end

def cat_facts(number)
    @v.sms("#{number}", "Thanks for signing up for Cat Facts! You now will receive fun daily facts about CATS!>o<")
    wait_for_response(1, number)
    @v.sms("#{number}", "Cats use their tails for balance and have nearly individual bones in them! To cancel daily Cat Facts, reply 'CAT FACTS: cancel'")
    sleep 5
    @v.sms("#{number}", "Would you like to receive a Cat Fact every hour? <reply 'CAT FACTS: oaiwje0923r1mncan' to cancel>")
    wait_for_response(1, number)
    @v.sms("#{number}", "Command not recognized. You have a <year> subscription to Cat Facts and will receive fun <hourly> updates!")    
    p "Dropping to send_fact routine until break count is hit"
    send_fact(number, 1, 2)   
    @v.sms("#{number}", "Command not recognized. Please let us know you are human to cancel by completing the following sentence: Your favorite animal is the 'ANIMAL: insertnamehere'.")   
   wait_for_response(1, number)
   @v.sms("#{number}", "INCORRECT. Your favorite animal is the cat. You will continue to receive Cat Facts every <hour>.")  
   p "Dropping to send_fact routine until break count of 2 is hit"
   send_fact(number, 1, 2)
   @v.sms("#{number}", "Welcome to Cat Facts! Did you know that the first cat show was held in 1871 at the Crystal Palace in London? Mee-wow!")   
   wait_for_response(1, number)
   @v.sms("#{number}", "Thanks for texting Cat Facts! Now, every time you text you will receive an instant Cat Fact. To cancel, reply 'CAT FACTS: chrykutfgh5764gvhtfvkigdrf678'")
   wait_for_response(1, number)
   @v.sms("#{number}", "<Command not recognized.> Did you know there are about 100 distinct breeds of domestic cat? Plenty of furry love!")
   wait_for_response(1, number)
   @v.sms("#{number}", "Cats can see well in the dark!")
      p "Dropping to send_fact routine until break count of 2 is hit"
   send_fact(number, 1, 2)
   @v.sms("#{number}", "Cats bury their faces to cover their tails from predators. <To cancel Cat Facts reply 'CAT FACTS:dghdfjnhddhtd56666443hdfdfdfuutregjbvcyu65468990'")
   wait_for_response(1, number)
   @v.sms("#{number}", "You really want to cancel? Please answer the following question to confirm you're human: Your favorite animal is the (blank).")
   wait_for_response(1, number)  
   favorite = check_favorite(number) 
@v.sms("#{number}", "INCORRECT: You said your favorite animal is the <#{favorite}>. You will continue to receive <hourly> cat facts.")
    p 'loop forever!'
   send_fact(number, 1, 99999999999)   
end 
print '> '
number = gets.chomp
cat_facts(number)
